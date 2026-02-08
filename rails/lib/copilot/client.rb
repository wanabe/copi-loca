module Copilot
  class Client
    attr_reader :socket

    def initialize(cli_url:, &block)
      @cli_url = cli_url

      return unless block_given?
      start(&block)
    end

    def start
      uri = URI.parse(@cli_url)
      @socket = TCPSocket.new(uri.host, uri.port)
      if block_given?
        begin
          yield self
        ensure
          stop
        end
      end
    end

    def stop
      @socket.close
    end

    def call(method, params = {})
      id = SecureRandom.uuid
      request = {
        jsonrpc: "2.0",
        id: id,
        method: method,
        params: params
      }
      json = JSON.generate(request)
      @socket.write("Content-Length: ", json.bytesize, "\r\n\r\n", json)
      id
    end

    def gets
      header = @socket.gets("\r\n\r\n")
      content_length = header.match(/Content-Length: (\d+)/)[1].to_i
      response = @socket.read(content_length)
      JSON.parse(response, symbolize_names: true)
    end
  end
end
