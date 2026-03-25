# frozen_string_literal: true
# rbs_inline: enabled

class Git::Diff < Git::Command
  # @rbs!
  #   attr_accessor src_ref (): String?
  #   attr_accessor dst_ref (): String?
  #   attr_accessor cached (): bool
  #   attr_accessor patches (): Array[Git::Diff::Patch]
  #   attr_accessor paths (): Array[String]

  attribute :src_ref, :string
  attribute :dst_ref, :string
  attribute :cached, :boolean
  attribute :patches, default: lambda {
    [] #: Array[Git::Diff::Patch]
  }
  attribute :paths, default: lambda {
    [] #: Array[String]
  }

  # @rbs return: String
  def command
    "diff"
  end

  # @rbs return: self
  def run
    args = [
      cached ? "--cached" : nil,
      [src_ref, dst_ref].compact.join("..").presence
    ].compact
    if paths.any?
      args << "--"
      args.concat(paths)
    end
    super(*args)
  end

  # @rbs return: void
  def template
    partial :patches, Patch, quantity: "*"
  end

  class Patch < ApplicationRepresenter
    # @rbs!
    #   attr_accessor header (): Git::Diff::Header
    #   attr_accessor hunks (): Array[Git::Diff::Hunk]

    attribute :header
    attribute :hunks, default: lambda {
      [] #: Array[Git::Diff::Hunk]
    }

    # @rbs return: void
    def template
      partial :header, Git::Diff::Header
      partial :hunks, Git::Diff::Hunk, quantity: "*"
    end

    # @rbs return: Symbol
    def type
      if header.has_new_file
        :new
      elsif header.has_deleted_mode
        :delete
      else
        :modify
      end
    end
  end

  class Header < ApplicationRepresenter
    # @rbs!
    #   attr_accessor path (): String
    #   attr_accessor has_old_mode (): bool
    #   attr_accessor old_mode (): String
    #   attr_accessor has_new_mode (): bool
    #   attr_accessor new_mode (): String
    #   attr_accessor has_new_file (): bool
    #   attr_accessor has_deleted_mode (): bool
    #   attr_accessor deleted_mode (): String
    #   attr_accessor has_index (): bool
    #   attr_accessor index_src (): String
    #   attr_accessor index_dst (): String
    #   attr_accessor has_index_mode (): bool
    #   attr_accessor index_mode (): String
    #   attr_accessor has_file_header (): bool
    #   attr_accessor src_file (): String
    #   attr_accessor dst_file (): String

    attribute :src_path, :string
    attribute :dst_path, :string
    attribute :has_old_mode, :boolean, default: false
    attribute :old_mode, :string
    attribute :has_new_mode, :boolean, default: false
    attribute :new_mode, :string
    attribute :has_new_file, :boolean, default: false
    attribute :has_deleted_mode, :boolean, default: false
    attribute :deleted_mode, :string
    attribute :has_index, :boolean, default: false
    attribute :index_src, :string
    attribute :index_dst, :string
    attribute :has_index_mode, :boolean, default: false
    attribute :index_mode, :string
    attribute :has_file_header, :boolean, default: false
    attribute :src_file, :string
    attribute :dst_file, :string
    attribute :has_similarity, :boolean, default: false
    attribute :similarity_index, :integer
    attribute :rename_from, :string
    attribute :rename_to, :string

    # @rbs return: void
    def template
      line do
        literal "diff --git a/"
        token :src_path, /\S+/
        literal " b/"
        token :dst_path, /\S+/
      end

      optional :has_old_mode do
        line do
          literal "old mode "
          token :old_mode, /\d+/
        end
      end

      optional :has_new_mode do
        line do
          literal "new "
          optional :has_new_file do
            literal "file "
          end
          literal "mode "
          token :new_mode, /\d+/
        end
      end

      optional :has_deleted_mode do
        line do
          literal "deleted file mode "
          token :deleted_mode, /\d+/
        end
      end

      optional :has_similarity do
        line do
          literal "similarity index "
          token :similarity_index, /\d+/
          literal "%"
        end
        line do
          literal "rename from "
          token :rename_from, /.+/
        end
        line do
          literal "rename to "
          token :rename_to, /.+/
        end
      end

      optional :has_index do
        line do
          literal "index "
          token :index_src, /[0-9a-f]+/
          literal ".."
          token :index_dst, /[0-9a-f]+/
          optional :has_index_mode do
            literal " "
            token :index_mode, /\d+/
          end
        end
      end

      optional :has_file_header do
        line do
          literal "--- "
          token :src_file, /.+/
        end
        line do
          literal "+++ "
          token :dst_file, /.+/
        end
      end
    end
  end

  class Hunk < ApplicationRepresenter
    # @rbs!
    #   attr_accessor src_range_start (): Integer
    #   attr_accessor has_src_range_end (): bool
    #   attr_reader src_range_end (): Integer
    #   attr_accessor dst_range_start (): Integer
    #   attr_accessor has_dst_range_end (): bool
    #   attr_reader dst_range_end (): Integer
    #   attr_accessor has_context (): bool
    #   attr_accessor context (): String
    #   attr_accessor lines (): Array[Git::Diff::Hunk::Line]

    attribute :src_range_start, :integer
    attribute :has_src_range_end, :boolean, default: false
    attribute :src_range_end, :integer
    attribute :dst_range_start, :integer
    attribute :has_dst_range_end, :boolean, default: false
    attribute :dst_range_end, :integer
    attribute :has_context, :boolean, default: false
    attribute :context, :string
    attribute :lines, default: lambda {
      [] #: Array[Git::Diff::Hunk::Line]
    }

    # @rbs value: Integer
    # @rbs return: void
    def src_range_end=(value)
      self.has_src_range_end = value.present?
      super
    end

    # @rbs value: Integer
    # @rbs return: void
    def dst_range_end=(value)
      self.has_dst_range_end = value.present?
      super
    end

    # @rbs return: void
    def template
      line do
        literal "@@ -"
        token :src_range_start, /\d+/
        optional :has_src_range_end do
          literal ","
          token :src_range_end, /\d+/
        end
        literal " +"
        token :dst_range_start, /\d+/
        optional :has_dst_range_end do
          literal ","
          token :dst_range_end, /\d+/
        end
        literal " @@"
        optional :has_context do
          literal " "
          token :context, /.*/
        end
      end

      partial :lines, Line, quantity: "*"
    end

    class Line < ApplicationRepresenter
      # @rbs!
      #   attr_accessor type (): Symbol
      #   attr_accessor content (): String

      attribute :type
      attribute :content, :string
      attribute :no_newline, :boolean, default: false

      # @rbs return: void
      def template
        line do
          token :type, /[-+ ]/, to: :to_sym
          token :content, /.*/
        end
        optional :no_newline do
          line do
            literal "\\ No newline at end of file"
          end
        end
      end
    end
  end
end
