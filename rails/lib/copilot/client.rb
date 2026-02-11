module Copilot
  class Client
    attr_reader :logger, :sessions, :messages

    def initialize(cli_url:, logger: nil, &block)
      @cli_url = cli_url
      @sessions = {}
      @messages = {}
      @waiting_ids = Set.new
      @logger = logger
      return unless block_given?

      start(&block)
    end

    def last_session
      sessions.values.last
    end

    def start
      uri = URI.parse(@cli_url)
      @socket = TCPSocket.new(uri.host, uri.port)
      logger&.info("Connected to Copilot CLI at #{@cli_url}")
      return self unless block_given?

      begin
        yield self
      ensure
        stop
      end
    end

    def stop
      if @socket
        unless @socket.closed?
          @socket.close
          logger&.info("Disconnected from Copilot CLI at #{@cli_url}")
        end
        @socket = nil
      end
    end

    def call(method, params = {})
      id = SecureRandom.uuid
      message = { id: id, method: method, params: params }
      @waiting_ids << id
      push(message)
      id
    end

    def push(message)
      raw_message = JSON.generate({ jsonrpc: "2.0" }.merge(message))
      @socket.write("Content-Length: ", raw_message.bytesize, "\r\n\r\n", raw_message)
      @on_send_callback&.call(message)
      logger&.debug("Sent message: #{message}")
    end

    def await(id)
      wait { messages[id] }
      message = messages.delete(id)
      error = message[:error]
      if error
        raise error.inspect
      end
      message[:result]
    end

    def readable?(timeout: nil)
      !!@socket.wait_readable(timeout)
    end

    def pop(timeout: nil)
      return unless readable?(timeout: timeout)

      header = @socket.gets("\r\n\r\n")
      content_length = header.match(/Content-Length: (\d+)/)[1].to_i
      raw_message = @socket.read(content_length)
      message = JSON.parse(raw_message, symbolize_names: true)
      @on_receive_callback&.call(message)
      id = message[:id]
      method = message[:method]
      if id && @waiting_ids.delete(id)
        messages[id] = message
      elsif method
        case method
        when /^session\./
          params = message[:params]
          session_id = params[:sessionId]
          sessions[session_id]&.handle(method, params)
        else
          logger&.warn("Unknown method received: #{method}")
        end
      end
      logger&.debug("Received message: #{message}")
      message
    end

    def wait(timeout: nil)
      timeout_at = Time.now + timeout if timeout
      loop do
        rest = timeout_at&.-(Time.now)
        return if rest && rest <= 0
        message = pop(timeout: rest)
        return unless message
        return message if yield(message)
      end
    end

    def create_session(params = {}, &block)
      Session.new(self, **params, &block)
    end

    def on_send(&block)
      @on_send_callback = block
    end

    def on_receive(&block)
      @on_receive_callback = block
    end

    private

    class << self
      def cache(cli_url: nil)
        @cache ||= {}
        client = @cache[cli_url]
        return client unless client.nil?
        if cli_url.nil?
          raise "No default CLI URL configured"
        end

        client = Client.new(cli_url: cli_url).tap(&:start)
        @cache[nil] ||= client
        @cache[cli_url] = client
      end

      def clear_cache
        return if @cache.nil?

        @cache.each_value(&:stop)
        @cache = {}
      end
    end
  end
end
