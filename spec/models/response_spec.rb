# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Response do
  let(:id) { 42 }
  let(:text) { 'Sample response text' }
  let(:response) { described_class.new(id: id, text: text) }
  let(:path) { File.join(Response::PATH_PREFIX, "#{id}#{Response::PATH_SUFFIX}") }

  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:write).and_call_original
    allow(Dir).to receive(:glob).and_call_original
  end

  describe '#load' do
    it 'loads text from file if exists' do
      allow(File).to receive(:read).with(path).and_return(text)
      expect(response.load.text).to eq(text)
    end

    it 'returns nil if file does not exist' do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
      expect(response.load).to be_nil
    end
  end

  describe '#save' do
    it 'writes text to file if valid' do
      allow(File).to receive(:write).with(path, text).and_return(true)
      expect(response.save).to be true
    end

    it 'returns false if not valid' do
      invalid = described_class.new(id: nil, text: nil)
      expect(invalid.save).to be false
    end

    it 'returns false and adds error if directory does not exist' do
      allow(File).to receive(:write).and_raise(Errno::ENOENT.new('No such directory'))
      expect(response.save).to be false
      expect(response.errors[:base]).to include(/Directory does not exist/)
    end
  end

  describe '#destroy!' do
    it 'deletes the file' do
      allow(File).to receive(:delete).with(path).and_return(true)
      expect { response.destroy! }.not_to raise_error
    end
  end

  describe '.find_by' do
    it 'returns loaded response if file exists' do
      allow(File).to receive(:read).with(path).and_return(text)
      expect(described_class.find_by(id: id).text).to eq(text)
    end

    it 'returns nil if file does not exist' do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
      expect(described_class.find_by(id: id)).to be_nil
    end
  end

  describe '.find' do
    it 'returns loaded response if file exists' do
      allow(File).to receive(:read).with(path).and_return(text)
      expect(described_class.find(id).text).to eq(text)
    end

    it 'raises RecordNotFound if file does not exist' do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
      expect { described_class.find(id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '.all' do
    it 'returns all loaded responses for numeric filenames' do
      files = [File.join(Response::PATH_PREFIX, '1.response.md'), File.join(Response::PATH_PREFIX, '2.response.md')]
      allow(Dir).to receive(:glob).and_return(files)
      allow(File).to receive(:read).with(files[0]).and_return('foo')
      allow(File).to receive(:read).with(files[1]).and_return('bar')
      responses = described_class.all
      expect(responses.map(&:id)).to contain_exactly(1, 2)
      expect(responses.map(&:text)).to contain_exactly('foo', 'bar')
    end

    it 'skips files with non-numeric names' do
      files = [File.join(Response::PATH_PREFIX, 'abc.response.md')]
      allow(Dir).to receive(:glob).and_return(files)
      expect(described_class.all).to be_empty
    end
  end

  describe '.max_id' do
    it 'returns the maximum id among all responses' do
      allow(described_class).to receive(:all).and_return([
        described_class.new(id: 1),
        described_class.new(id: 5),
        described_class.new(id: 3)
      ])
      expect(described_class.max_id).to eq(5)
    end

    it 'returns 0 if no responses exist' do
      allow(described_class).to receive(:all).and_return([])
      expect(described_class.max_id).to eq(0)
    end
  end

  describe '#valid?' do
    it 'is valid with id and text' do
      expect(response).to be_valid
    end

    it 'is not valid without id or text' do
      expect(described_class.new(id: nil, text: nil)).not_to be_valid
    end
  end

  describe '#path' do
    it 'returns the correct file path' do
      expect(response.send(:path)).to eq(path)
    end
  end
end
