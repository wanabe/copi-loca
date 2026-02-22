require 'rails_helper'
require 'copilot/session'
require 'copilot/client'

RSpec.describe Copilot::Session do
  let(:client) { instance_double(Copilot::Client, sessions: {}, logger: instance_double('Logger', info: nil, warn: nil)) }

  describe '#initialize' do
    it 'creates a new session if session_id is nil' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client)
      expect(session.session_id).to eq('sid123')
      expect(client.sessions['sid123']).to eq(session)
    end

    it 'resumes an existing session if session_id is given' do
      allow(client).to receive(:call).and_return(nil)
      allow(client).to receive(:await).and_return(nil)
      session = described_class.new(client, session_id: 'sid456')
      expect(session.session_id).to eq('sid456')
      expect(client.sessions['sid456']).to eq(session)
    end

    it 'yields self if block is given and destroys after block' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid789' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid789' })
      allow_any_instance_of(described_class).to receive(:destroy)
      yielded = nil
      described_class.new(client) { |s| yielded = s }
      expect(yielded).to be_a(described_class)
    end
  end

  describe '#idle?' do
    it 'returns true if idle' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client)
      expect(session.idle?).to eq(true)
    end
  end

  describe '#destroy' do
    it 'removes session from client.sessions' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client)
      client.sessions['sid123'] = session
      allow(session).to receive(:call)
      session.destroy
      expect(client.sessions).not_to have_key('sid123')
    end
  end

  describe '#send' do
    it 'sets idle to false and calls session.send' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client)
      allow(session).to receive(:call)
      session.send('hello')
      expect(session.idle?).to eq(false)
    end
  end

  describe '#call' do
    it 'calls client.call with sessionId' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client)
      expect(client).to receive(:call).with('test.method', hash_including(sessionId: 'sid123'))
      session.call('test.method', foo: 'bar')
    end
  end

  describe '#await' do
    it 'delegates to client.await' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client)
      allow(client).to receive(:await).and_return('result')
      expect(session.await('id')).to eq('result')
    end
  end

  describe '#handle' do
    it 'handles session.event and updates idle/turn_id' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client)
      expect(session.idle?).to eq(true)
      session.handle('id', 'session.event', { event: { type: 'assistant.turn_start', data: { turnId: 't1' } } })
      expect(session.turn_id).to eq('t1')
      session.handle('id', 'session.event', { event: { type: 'assistant.turn_end', data: {} } })
      expect(session.turn_id).to be_nil
      session.handle('id', 'session.event', { event: { type: 'session.idle', data: {} } })
      expect(session.idle?).to eq(true)
    end

    it 'handles session.lifecycle' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client)
      expect { session.handle('id', 'session.lifecycle', { type: 'foo', metadata: {} }) }.not_to raise_error
    end

    it 'handles tool.call with handler' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      handler = proc { |**args| 'tool result' }
      session = described_class.new(client, tools: [ { name: 'mytool', handler: handler } ])
      expect(client).to receive(:respond).with('id', result: hash_including(result: hash_including(textResultForLlm: 'tool result')))
      session.handle('id', 'tool.call', { toolName: 'mytool', arguments: {} })
    end

    it 'returns tool handler result hash unchanged' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      handler_result = {
        result: {
          textResultForLlm: 'perfect',
          resultType: 'success'
        }
      }
      handler = proc { |**args| handler_result }
      session = described_class.new(client, tools: [ { name: 'mytool', handler: handler } ])
      expect(client).to receive(:respond).with('id', result: handler_result)
      session.handle('id', 'tool.call', { toolName: 'mytool', arguments: {} })
    end

    it 'handles tool.call when handler raises exception' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      handler = proc { |**args| raise 'tool error' }
      session = described_class.new(client, tools: [ { name: 'mytool', handler: handler } ])
      expect(client).to receive(:respond).with('id', result: hash_including(result: hash_including(resultType: 'failure')))
      session.handle('id', 'tool.call', { toolName: 'mytool', arguments: {} })
    end

    it 'handles tool.call without handler' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client, tools: [ { name: 'mytool', handler: nil } ])
      expect(client).to receive(:respond).with('id', error: hash_including(code: -32000))
      session.handle('id', 'tool.call', { toolName: 'mytool', arguments: {} })
    end

    it 'handles unknown method' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client)
      expect(client.logger).to receive(:warn).with(/Unknown session method/)
      session.handle('id', 'unknown.method', {})
    end
  end

  describe '#on' do
    it 'calls event handler for type when event occurs' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client)
      called = false
      session.on('session.idle') { called = true }
      session.handle_event('session.idle')
      expect(called).to eq(true)
    end
    it 'calls global event handler when event occurs' do
      allow(client).to receive(:call).and_return({ sessionId: 'sid123' })
      allow(client).to receive(:await).and_return({ sessionId: 'sid123' })
      session = described_class.new(client)
      called = nil
      session.on { |type, **data| called = type }
      session.handle_event('assistant.turn_start')
      expect(called).to eq('assistant.turn_start')
    end
  end
end
