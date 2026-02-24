require 'rails_helper'
require 'copilot/client'

describe Copilot::Client do
  let(:cli_url) { 'tcp://localhost:3100' }
  let(:logger) { instance_double('Logger', info: nil, debug: nil, warn: nil) }

  describe '.cache' do
    before do
      allow(Copilot::Client).to receive(:new).and_wrap_original do |m, **args|
        client = m.call(**args)
        allow(client).to receive(:start).and_return(client)
        client
      end
      Copilot::Client.clear_cache
    end
    it 'returns cached client for given url' do
      client1 = Copilot::Client.cache(cli_url: cli_url)
      client2 = Copilot::Client.cache(cli_url: cli_url)
      expect(client2).to be_a(Copilot::Client)
      expect(client2).to equal(client1)
    end
    it 'raises error if cli_url is nil' do
      expect { Copilot::Client.cache(cli_url: nil) }.to raise_error(/No default CLI URL configured/)
    end
    it 'removes all cached clients and creates new instance' do
      client1 = Copilot::Client.cache(cli_url: cli_url)
      Copilot::Client.clear_cache
      client2 = Copilot::Client.cache(cli_url: cli_url)
      expect(client2).to be_a(Copilot::Client)
      expect(client2).not_to equal(client1)
    end
  end

  describe '#initialize' do
    it 'sets cli_url, logger, sessions, messages' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      expect(client.logger).to eq(logger)
      expect(client.sessions).to eq({})
      expect(client.messages).to eq({})
    end

    it 'yields self if block is given' do
      yielded = nil
      socket = instance_double('TCPSocket', closed?: false, close: nil)
      allow(TCPSocket).to receive(:new).and_return(socket)
      described_class.new(cli_url: cli_url, logger: logger) { |c| yielded = c }
      expect(yielded).to be_a(Copilot::Client)
    end
  end

  describe '#last_session' do
    it 'returns last session' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      client.sessions['a'] = 1
      client.sessions['b'] = 2
      expect(client.last_session).to eq(2)
    end
  end

  describe '#start' do
    it 'calls logger info on connect' do
      socket = instance_double('TCPSocket', closed?: false, close: nil)
      allow(TCPSocket).to receive(:new).and_return(socket)
      client = described_class.new(cli_url: cli_url, logger: logger)
      allow(logger).to receive(:info)
      client.start { }
      expect(logger).to have_received(:info).with(/Connected/)
    end
  end

  describe '#stop' do
    it 'calls logger info on disconnect' do
      socket = instance_double('TCPSocket', closed?: false, close: nil)
      allow(TCPSocket).to receive(:new).and_return(socket)
      client = described_class.new(cli_url: cli_url, logger: logger)
      client.start { }
      allow(socket).to receive(:closed?).and_return(false)
      allow(logger).to receive(:info)
      client.stop
      expect(logger).to have_received(:info).at_least(:once).with(/Disconnected/)
    end
  end

  describe '#call' do
    it 'pushes message and returns id' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      allow(SecureRandom).to receive(:uuid).and_return('id123')
      allow(client).to receive(:push)
      id = client.call('method', { foo: 'bar' })
      expect(id).to eq('id123')
      expect(client.messages).not_to have_key('id123')
    end
  end

  describe '#push' do
    it 'writes message to socket and calls logger' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      socket = instance_double('TCPSocket', write: nil)
      allow(client).to receive(:io).and_return(socket)
      allow(socket).to receive(:write)
      allow(logger).to receive(:debug)
      client.push({ id: 'id', method: 'm' })
      expect(socket).to have_received(:write)
      expect(logger).to have_received(:debug)
    end
  end

  describe '#respond' do
    it 'pushes response message' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      allow(client).to receive(:push)
      client.respond('id', result: 'ok')
      expect(client).to have_received(:push).with(hash_including(id: 'id', result: 'ok'))
    end
  end

  describe '#await' do
    it 'returns result if no error' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      client.messages['id'] = { id: 'id', result: 'ok' }
      allow(client).to receive(:wait).and_yield
      expect(client.await('id')).to eq('ok')
    end
    it 'raises error if error present' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      client.messages['id'] = { id: 'id', error: 'fail' }
      allow(client).to receive(:wait).and_yield
      expect { client.await('id') }.to raise_error(/fail/)
    end
  end

  describe '#readable?' do
    it 'calls wait_readable on socket' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      socket = instance_double('TCPSocket', wait_readable: true)
      allow(client).to receive(:io).and_return(socket)
      expect(client.readable?(timeout: 1)).to eq(true)
    end
  end

  describe '#pop' do
    it 'returns nil if not readable' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      allow(client).to receive(:readable?).and_return(false)
      expect(client.pop).to be_nil
    end
    it 'parses and stores message' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      socket = instance_double('TCPSocket')
      allow(client).to receive(:io).and_return(socket)
      allow(client).to receive(:readable?).and_return(true)
      allow(socket).to receive(:gets).and_return("Content-Length: 10\r\n\r\n")
      allow(socket).to receive(:read).and_return('{"id":"id","result":"ok"}')
      allow(logger).to receive(:debug)

      expect(client.pop).to include(:id, :result)
      expect(logger).to have_received(:debug).with(/Received/)
    end

    it 'handles method starting with session. or tool. in message' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      socket = instance_double('TCPSocket')
      allow(client).to receive(:io).and_return(socket)
      allow(client).to receive(:readable?).and_return(true)
      allow(socket).to receive(:gets).and_return("Content-Length: 10\r\n\r\n")
      allow(socket).to receive(:read).and_return('{"id":"id","method":"session.create","params":{"sessionId":"sess1"}}')
      session = instance_double('Session')
      client.sessions['sess1'] = session
      allow(session).to receive(:handle)
      allow(logger).to receive(:debug)
      client.pop
      expect(session).to have_received(:handle).with('id', 'session.create', { sessionId: 'sess1' })
      expect(logger).to have_received(:debug)
    end

    it 'handles method not starting with session. or tool. in message' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      socket = instance_double('TCPSocket')
      allow(client).to receive(:io).and_return(socket)
      allow(client).to receive(:readable?).and_return(true)
      allow(socket).to receive(:gets).and_return("Content-Length: 10\r\n\r\n")
      allow(socket).to receive(:read).and_return('{"id":"id","method":"other.method","params":{"sessionId":"sess1"}}')
      allow(logger).to receive(:warn)
      allow(logger).to receive(:debug)
      client.pop
      expect(logger).to have_received(:warn).with(/Unknown method received/)
      expect(logger).to have_received(:debug)
    end
  end

  describe '#wait' do
    it 'returns message matching block' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      allow(client).to receive(:pop).and_return({ id: 'id', result: 'ok' })
      expect(client.wait { |m| m[:id] == 'id' }).to include(:id, :result)
    end
  end

  describe '#create_session' do
    it 'creates a Session' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      session = instance_double('Session')
      allow(Copilot::Session).to receive(:new).and_return(session)
      expect(client.create_session).to eq(session)
    end
  end

  describe '#on_send' do
    it 'sets on_send callback' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      cb = proc { }
      expect { client.on_send(&cb) }.not_to raise_error
    end
  end

  describe '#on_receive' do
    it 'sets on_receive callback' do
      client = described_class.new(cli_url: cli_url, logger: logger)
      cb = proc { }
      expect { client.on_receive(&cb) }.not_to raise_error
    end
  end
end
