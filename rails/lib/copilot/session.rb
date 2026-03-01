# frozen_string_literal: true

module Copilot
  class Session
    attr_reader :session_id, :turn_id

    def initialize(client, session_id: nil, tools: [], **params)
      @client = client
      @tool_handlers = tools.to_h do |tool|
        [tool[:name].to_sym, tool[:handler]]
      end
      tools = tools.map do |tool|
        {
          name: tool[:name],
          description: tool[:description],
          required: tool[:required],
          parameters: tool[:parameters]
        }.compact
      end
      if session_id
        await @client.call("session.resume", sessionId: session_id, tools: tools, **params)
        @session_id = session_id
      else
        result = await @client.call("session.create", tools: tools, **params)
        @session_id = result[:sessionId]
      end
      @client.logger&.info("Created session #{@session_id}")
      @client.sessions[@session_id] = self
      @idle = true
      @turn_id = nil
      @event_handlers = {}
      return unless block_given?

      begin
        yield self
      ensure
        destroy
      end
    end

    def idle?
      @idle
    end

    def destroy
      return unless @client.sessions[@session_id]

      await call("session.destroy")
      @client.logger&.info("Destroyed session #{@session_id}")
      @client.sessions.delete(@session_id)
    end

    def send(prompt, attachments: nil)
      @idle = false
      call("session.send", **{ prompt: prompt, attachments: attachments }.compact)
    end

    def call(method, params = {})
      params_with_session = params.merge(sessionId: @session_id)
      @client.call(method, params_with_session)
    end

    delegate :await, to: :@client

    def handle(id, method, params)
      case method
      when "session.event"
        type, data = params[:event].values_at(:type, :data)
        handle_event(type, **data)
      when "session.lifecycle"
        type, metadata = params.values_at(:type, :metadata)
        handle_lifecycle(type, **metadata)
      when "tool.call"
        name, arguments = params.values_at(:toolName, :arguments)
        handler = @tool_handlers[name.to_sym]
        handle_tool_call(id, name, handler, arguments)
      else
        @client.logger&.warn("Unknown session method: #{method}")
      end
    end

    def handle_event(type, **data)
      case type
      when "session.idle"
        @idle = true
      when "assistant.turn_start"
        @turn_id = data[:turnId]
      when "assistant.turn_end"
        @turn_id = nil
      end
      @event_handlers[type]&.call(**data)
      @event_handler&.call(type, **data)
    end

    def handle_lifecycle(type, **metadata)
      # No-op for now
    end

    def handle_tool_call(id, name, handler, arguments)
      unless handler
        @client.logger&.warn("No handler for tool: #{name}")
        @client.respond(id, error: { code: -32_000, message: "Tool '#{name}' not found in this session" })
        return
      end
      result = call_tool_handler(handler, arguments)
      @client.respond(id, result: result)
    end

    def call_tool_handler(handler, arguments)
      raw_result = handler.call(**arguments)
      if raw_result.is_a?(Hash)
        result = raw_result[:result] || raw_result["result"]
        if result.is_a?(Hash)
          keys = (result.keys.map(&:to_sym) - %i[error toolTelemetry]).sort
          return raw_result if keys == %i[resultType textResultForLlm]
        end
      end

      {
        result: {
          textResultForLlm: raw_result.to_s,
          resultType: "success",
          toolTelemetry: {}
        }
      }
    rescue StandardError => e
      @client.logger&.warn("Error in tool handler: #{e.message}")
      {
        result: {
          textResultForLlm: "Failed to execute",
          resultType: "failure",
          error: e.full_message
        }
      }
    end

    def on(type = nil, &block)
      if type
        @event_handlers[type] ||= block
      else
        @event_handler = block
      end
    end
  end
end
