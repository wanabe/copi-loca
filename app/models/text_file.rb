# frozen_string_literal: true
# rbs_inline: enabled

class TextFile < ApplicationRepresenter
  PATH_PREFIX = ""
  PATH_SUFFIX = ""
  ID_PATTERN = //
  ID_PATTERN_INDEX = 0

  # @rbs return: self | nil
  def load
    parse(File.read(path))
    self
  rescue Errno::ENOENT
    nil
  end

  # @rbs return: bool
  def save
    return false unless valid?

    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, render)
    true
  rescue Errno::ENOENT => e
    errors.add(:base, "Cannot save file: #{e.message}")
    false
  end

  # @rbs return: bool
  def persisted?
    File.exist?(path)
  end

  # @rbs return: void
  def destroy!
    File.delete(path)
  end

  # @rbs return: Integer
  def id = 0

  class << self
    # @rbs value: untyped # TODO: Specify more precise type
    # @rbs return: Hash[Symbol, Integer]
    def primary_condition(value)
      { id: value.to_i }
    end

    # @rbs id: untyped # TODO: Specify more precise type
    # @rbs return: String
    def path_pattern(id)
      "#{self::PATH_PREFIX}#{id}#{self::PATH_SUFFIX}"
    end

    # @rbs file_path: String
    # @rbs return: TextFile | nil
    def from_path(file_path)
      id = file_path[self::ID_PATTERN, self::ID_PATTERN_INDEX]
      return nil unless id

      new(**primary_condition(id))
    end

    # @rbs **conditions: untyped # TODO: Specify more precise type
    # @rbs return: TextFile | nil
    def find_by(**conditions)
      new(**conditions).load #: TextFile | nil
    end

    # @rbs value: untyped # TODO: Specify more precise type
    # @rbs return: TextFile
    def find(value)
      condition = primary_condition(value)
      find_by(**condition) || raise(ActiveRecord::RecordNotFound, "#{name} not found with #{condition}")
    end

    # @rbs return: Array[TextFile]
    def all
      text_files = Dir.glob(path_pattern("*")).filter_map do |file_path|
        from_path(file_path) #: TextFile | nil
      end
      text_files.sort_by!(&:id)
      text_files #: Array[TextFile]
    end

    # @rbs return: Integer
    def max_id
      all.map(&:id).max || 0
    end
  end

  private

  # @rbs return: String
  def path
    self.class.path_pattern(id)
  end
end
