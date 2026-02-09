module Copilot
  class Session
    attr_reader :session_id, :turn_id

    def initialize(client, session_id: nil, **params)
      @client = client
      if session_id
        await @client.call("session.resume", sessionId: session_id, **params)
        @session_id = session_id
      else
        result = await @client.call("session.create", params)
        @session_id = result[:sessionId]
      end
      @client.logger&.info("Created session #{@session_id}")
      @client.sessions[@session_id] = self
      @idle = true
      @turn_id = nil
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

    def send(prompt)
      @idle = false
      call("session.send", prompt: prompt)
    end

    def call(method, params = {})
      params_with_session = params.merge(sessionId: @session_id)
      @client.call(method, params_with_session)
    end

    def await(id)
      @client.await(id)
    end

    def handle(method, params)
      case method
      when "session.event"
        type, data = params[:event].values_at(:type, :data)
        handle_event(type, **data)
      when "session.lifecycle"
        type, metadata = params.values_at(:type, :metadata)
        handle_lifecycle(type, **metadata)
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
      else
        @client.logger&.warn("Unknown event type: #{type}")
      end
      @event_handler&.call(type, **data)
    end

    def handle_lifecycle(type, **metadata)
      # No-op for now
    end

    def on(&block)
      @event_handler = block
    end
  end
end
