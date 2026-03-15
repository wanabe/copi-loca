# frozen_string_literal: true

class TextFile
  include ActiveModel::Model
  include ActiveModel::Attributes
  include TextRepresenter::Representable

  def load
    parse(File.read(path))
    self
  rescue Errno::ENOENT
    nil
  end

  def save
    return false unless valid?

    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, render)
    true
  rescue Errno::ENOENT => e
    errors.add(:base, "Cannot save file: #{e.message}")
    false
  end

  def persisted?
    File.exist?(path)
  end

  def destroy!
    File.delete(path)
  end

  class << self
    def primary_condition(value)
      { id: value.to_i }
    end

    def path_pattern(id)
      "#{self::PATH_PREFIX}#{id}#{self::PATH_SUFFIX}"
    end

    def from_path(file_path)
      id = file_path[*self::ID_PATTERN]
      return nil unless id

      new(**primary_condition(id))
    end

    def find_by(**conditions)
      new(**conditions).load
    end

    def find(value)
      condition = primary_condition(value)
      find_by(**condition) || raise(ActiveRecord::RecordNotFound, "#{name} not found with #{condition}")
    end

    def all
      Dir.glob(path_pattern("*")).filter_map do |file_path|
        from_path(file_path)&.load
      end.sort_by(&:id)
    end

    def max_id
      all.map(&:id).max || 0
    end
  end

  private

  def path
    self.class.path_pattern(id)
  end
end
