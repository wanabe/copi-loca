class Response
  PATH_PREFIX = Rails.root.join(".github/responses").to_s.freeze
  PATH_SUFFIX = ".response.md".freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :text, :string

  validates :id, presence: true
  validates :text, presence: true

  def load
    self.text = File.read(path)
    self
  rescue Errno::ENOENT
    nil
  end

  def save
    return false unless valid?
    File.write(path, text)
    true
  rescue Errno::ENOENT => e
    errors.add(:base, "Directory does not exist: #{e.message}")
    false
  end

  class << self
    def find_by(id:)
      new(id: id).load
    end

    def find(id)
      find_by(id: id) || raise(ActiveRecord::RecordNotFound, "#{name} not found with id: #{id}")
    end

    def all
      Dir.glob(File.join(PATH_PREFIX, "*#{PATH_SUFFIX}")).map do |file_path|
        id = File.basename(file_path, PATH_SUFFIX)
        if id =~ /^\d+$/
          new(id: id.to_i).load
        end
      end.compact
    end

    def max_id
      all.map(&:id).max || 0
    end
  end

  private

  def path
    File.join(PATH_PREFIX, "#{id}#{PATH_SUFFIX}")
  end
end
