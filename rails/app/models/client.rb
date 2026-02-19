class Client
  include ActiveModel::Model

  CLI_URL = "tcp://copilot:3100"

  class << self
    delegate :create_session, :resume_session, :available_models, :wait, to: :instance

    def instance
      @instance ||= new
    end
  end

  attr_reader :copilot_client

  def initialize
    super()
    @copilot_client = Copilot::Client.cache(cli_url: CLI_URL)
    @waiting_map = {}
    @last_rpc_message = nil

    @copilot_client.on_send do |data|
      session_id = data.dig(:params, :sessionId)
      session = Session.find_by(id: session_id) if session_id
      if session
        rpc_id = data[:id]
        @waiting_map[rpc_id] = session if rpc_id
        @last_rpc_message = session.handle(:outgoing, rpc_id, data)
      end
      Rails.logger.debug("Sent data: #{data}")
    end

    @copilot_client.on_receive do |data|
      session_id = data.dig(:params, :sessionId)
      session = Session.find_by(id: session_id) if session_id
      rpc_id = data[:id]
      session ||= @waiting_map.delete(rpc_id) if rpc_id
      if session
        @last_rpc_message = session.handle(:incoming, rpc_id, data)
      end
      Rails.logger.debug("Received data: #{data}")
    end
  end

  def create_session(session)
    copilot_session = copilot_client.create_session(model: session.model, **session.options)
    session.id = copilot_session.session_id
    copilot_session
  end

  def resume_session(session)
    copilot_client.sessions[session.id] ||
      copilot_client.create_session(session_id: session.id, **session.options)
  end

  def available_models
    return @available_models if @available_models
    models = copilot_client.await(copilot_client.call("models.list"))[:models]
    @available_models = models.sort_by { |model| [ model.dig(:billing, :multiplier), model[:id] ] }
  end

  def wait
    copilot_client.wait do
      rpc_message = @last_rpc_message
      @last_rpc_message = nil
      yield(rpc_message)
    end
  end
end
