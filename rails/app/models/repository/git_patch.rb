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

    def represent
      define :nested, :header, FileHeader
      define :nested, :hunks, Hunk, quantity: "+"
    end

    class NoHeader < TextRepresenter::Base
      attribute :hunks

      def represent
        define :nested, :hunks, Hunk, quantity: "+"
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

      def represent
        define :nested, :git_file_header, GitFileHeader
        define :nested, :extended_header, ExtendedHeader, quantity: "?"
        define :nested, :from_file_header, FromFileHeader
        define :nested, :to_file_header, ToFileHeader
      end
    end

    class GitFileHeader < TextRepresenter::Base
      attribute :from_file_path
      attribute :to_file_path

      def represent
        define :line do
          define :fixed, "diff --git a/"
          define :pattern, :from_file_path, /[^\s]+/
          define :fixed, " b/"
          define :pattern, :to_file_path, /[^\s]+/
        end
      end
    end

    class ExtendedHeader < TextRepresenter::Base
      attribute :from_hash
      attribute :to_hash
      attribute :mode

      def represent
        define :line do
          define :fixed, "index "
          define :pattern, :from_hash, /[0-9a-f]+/
          define :fixed, ".."
          define :pattern, :to_hash, /[0-9a-f]+/
          define :fixed, " "
          define :pattern, :mode, /\d+/
        end
      end
    end

    class FromFileHeader < TextRepresenter::Base
      attribute :file_path

      def represent
        define :line do
          define :fixed, "--- a/"
          define :pattern, :file_path, /[^\s]+/
        end
      end
    end

    class ToFileHeader < TextRepresenter::Base
      attribute :file_path

      def represent
        define :line do
          define :fixed, "+++ b/"
          define :pattern, :file_path, /[^\s]+/
        end
      end
    end

    class Hunk < TextRepresenter::Base
      attribute :header
      attribute :lines

      def represent
        define :nested, :header, HunkHeader
        define :nested, :lines, HunkLine, quantity: "+", parent: :hunk, index: :index
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

      def represent
        define :line do
          define :fixed, "@@ -"
          define :pattern, :from_line, /\d+/, to: :to_i
          define :fixed, ","
          define :pattern, :from_length, /\d+/, to: :to_i
          define :fixed, " +"
          define :pattern, :to_line, /\d+/, to: :to_i
          define :fixed, ","
          define :pattern, :to_length, /\d+/, to: :to_i
          define :fixed, " @@"

          define :quantity, :has_context, "?" do
            define :fixed, " "
            define :pattern, :context, /.+/
          end
        end
      end
    end

    class HunkLine < TextRepresenter::Base
      attribute :prefix
      attribute :content
      parent :hunk
      attribute :index

      def represent
        define :line do
          define :pattern, :prefix, /[-+ ]/
          define :pattern, :content, /.*/
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
