# frozen_string_literal: true

class Prompt < TextFile
  PATH_PREFIX = Rails.root.join("docs/prompts/").to_s.freeze
  PATH_SUFFIX = "/prompt.md"
  ID_PATTERN = [/\A#{Regexp.escape(PATH_PREFIX)}(\d+)#{Regexp.escape(PATH_SUFFIX)}\z/, 1].freeze

  COMMAND = ["copilot", "-s", "--model", "gpt-4.1", "--yolo", "-p"].freeze

  attribute :id, :integer
  attribute :text, :string
  attribute :has_metadata, :boolean, default: false
  attribute :name, :string
  attribute :description, :string

  validates :id, presence: true
  validates :text, presence: true

  def template
    optional :has_metadata do
      literal "---\n"
      line do
        literal "name: "
        token :name, /.+/
      end
      line do
        literal "description: "
        token :description, /.+/
      end
      literal "---\n"
    end
    token :text, /.*/m
  end

  def destroy!
    response&.destroy!
    super
  end

  def valid?
    self.has_metadata = name.present? && description.present?
    super
  end

  def run(n = 1)
    raise "Prompt is already running" if running?

    env = { "COPILOT_GITHUB_TOKEN" => ENV.fetch("COPILOCA_GITHUB_TOKEN", nil) }
    response = Response.new(id: id, text: "")
    n.times do
      IO.popen(env, [*COMMAND, text], err: %i[child out]) do |io|
        File.write(pid_path, io.pid.to_s)
        while (line = io.gets)
          response.text += line
          response.save
        end
        response
      ensure
        File.delete(pid_path) if running?
      end
    end
    response
  end

  def running?
    File.exist?(pid_path)
  end

  def pid
    return nil unless running?

    File.read(pid_path).to_i
  end

  def response
    return @response if @response_fetched

    @response_fetched = true
    @response = Response.find_by(id: id)
  end

  private

  def pid_path
    "#{Prompt::PATH_PREFIX}#{id}/pid"
  end
end
