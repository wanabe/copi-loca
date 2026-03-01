# frozen_string_literal: true

# example of git patch format:
# diff --git a/foo.rb b/foo.rb  <- FileHeader = GitFileHeader
# index 1234567..89abcde 100644                 + ExtendedHeader
# --- a/foo.rb                                  + FromFileHeader
# +++ b/foo.rb                                  + ToFileHeader
# @@ -1,3 +1,3 @@               <- Hunk = HunkHeader
#  some context line                      + [ HunkLine, ... ]
# -old line
# +new line
#  other context line

class Repository
  class GitPatch < TextRepresenter::Base
    attribute :header
    attribute :hunks

    def template
      partial :header, FileHeader
      partial :hunks, Hunk, quantity: "+"
    end

    class NoHeader < TextRepresenter::Base
      attribute :hunks

      def template
        partial :hunks, Hunk, quantity: "+"
      end

      def diff_line_at(diff_line_num)
        # 1 origin for line number
        cursor = 1

        hunks.each do |hunk|
          # hunk header line
          cursor += 1

          relative_line_num = diff_line_num - cursor
          return hunk.lines[relative_line_num] if (0...hunk.lines.size).cover?(relative_line_num)

          cursor += hunk.lines.size
        end
        nil
      end
    end

    class FileHeader < TextRepresenter::Base
      attribute :git_file_header
      attribute :extended_header
      attribute :from_file_header
      attribute :to_file_header

      def template
        partial :git_file_header, GitFileHeader
        partial :extended_header, ExtendedHeader, quantity: "?"
        partial :from_file_header, FromFileHeader
        partial :to_file_header, ToFileHeader
      end
    end

    class GitFileHeader < TextRepresenter::Base
      attribute :from_file_path
      attribute :to_file_path

      def template
        line do
          literal "diff --git a/"
          token :from_file_path, /[^\s]+/
          literal " b/"
          token :to_file_path, /[^\s]+/
        end
      end
    end

    class ExtendedHeader < TextRepresenter::Base
      attribute :from_hash
      attribute :to_hash
      attribute :mode

      def template
        line do
          literal "index "
          token :from_hash, /[0-9a-f]+/
          literal ".."
          token :to_hash, /[0-9a-f]+/
          literal " "
          token :mode, /\d+/
        end
      end
    end

    class FromFileHeader < TextRepresenter::Base
      attribute :file_path

      def template
        line do
          literal "--- a/"
          token :file_path, /[^\s]+/
        end
      end
    end

    class ToFileHeader < TextRepresenter::Base
      attribute :file_path

      def template
        line do
          literal "+++ b/"
          token :file_path, /[^\s]+/
        end
      end
    end

    class Hunk < TextRepresenter::Base
      attribute :header
      attribute :lines

      def template
        partial :header, HunkHeader
        partial :lines, HunkLine, quantity: "+", parent: :hunk, index: :index
      end

      def drop_if
        new_lines = []
        lines.each do |l|
          cond = yield l
          unless cond
            new_lines << l
            next
          end
          if l.prefix == "+"
            header.to_length -= 1
            next
          end
          header.to_length += 1 if l.prefix == "-"
          l.prefix = " "
          new_lines << l
        end
        self.lines = new_lines
      end

      def reduce_context(context_size)
        first_diff_index = lines.index { |l| l.prefix != " " }
        if first_diff_index
          extra_size = [0, first_diff_index - context_size].max
          if extra_size.positive?
            lines.shift(extra_size)
            header.from_line += extra_size
            header.from_length -= extra_size
            header.to_line += extra_size
            header.to_length -= extra_size
          end
        end

        last_diff_index = lines.rindex { |l| l.prefix != " " }
        return unless last_diff_index

        extra_size = [0, lines.size - 1 - last_diff_index - context_size].max
        return unless extra_size.positive?

        lines.pop(extra_size)
        header.from_length -= extra_size
        header.to_length -= extra_size
      end

      def reverse
        lines.each(&:reverse)
        header.from_line, header.to_line = header.to_line, header.from_line
        header.from_length, header.to_length = header.to_length, header.from_length
      end
    end

    class HunkHeader < TextRepresenter::Base
      attribute :from_line
      attribute :from_length
      attribute :to_line
      attribute :to_length
      attribute :has_context
      attribute :context

      def template
        line do
          literal "@@ -"
          token :from_line, /\d+/, to: :to_i
          literal ","
          token :from_length, /\d+/, to: :to_i
          literal " +"
          token :to_line, /\d+/, to: :to_i
          literal ","
          token :to_length, /\d+/, to: :to_i
          literal " @@"

          optional :has_context do
            literal " "
            token :context, /.+/
          end
        end
      end
    end

    class HunkLine < TextRepresenter::Base
      attribute :prefix
      attribute :content
      parent :hunk
      attribute :index

      def template
        line do
          token :prefix, /[-+ ]/
          token :content, /.*/
        end
      end

      def reverse
        case prefix
        when "-"
          self.prefix = "+"
        when "+"
          self.prefix = "-"
        end
      end
    end
  end
end
