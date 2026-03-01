# frozen_string_literal: true

require_relative "../../lib/text_representer"

RSpec.describe TextRepresenter do
  describe ".attribute" do
    let(:representer_klass) do
      Class.new(TextRepresenter::Base) do
        attribute :foo
      end
    end

    it "defines getter and setter for the attribute" do
      representer = representer_klass.new
      representer.foo = "bar"
      expect(representer.foo).to eq("bar")
    end

    it "stores attributes in the @attributes hash" do
      representer = representer_klass.new
      representer.foo = "bar"
      expect(representer.attributes).to eq({ foo: "bar" })
    end
  end

  describe ".parent" do
    let(:representer_klass) do
      Class.new(TextRepresenter::Base) do
        parent :parent_block
      end
    end

    it "defines getter and setter for the parent" do
      representer = representer_klass.new
      parent_representer = representer_klass.new
      representer.parent_block = parent_representer
      expect(representer.parent_block).to eq(parent_representer)
      expect(representer.parent).to eq(parent_representer)
    end
  end

  describe "#[]" do
    let(:representer_klass) do
      Class.new(TextRepresenter::Base) do
        attribute :foo
      end
    end

    it "allows access to attributes using symbol keys" do
      representer = representer_klass.new
      representer.foo = "bar"
      expect(representer[:foo]).to eq("bar")
    end

    it "returns nil for missing keys" do
      representer = representer_klass.new
      expect(representer[:missing]).to be_nil
    end
  end

  describe "#dig" do
    let(:representer_klass) do
      Class.new(TextRepresenter::Base) do
        attribute :foo
      end
    end

    it "allows digging into partial attributes" do
      representer = representer_klass.new
      partial_representer = representer_klass.new
      partial_representer.foo = "partial"
      representer.foo = partial_representer
      expect(representer.dig(:foo, :foo)).to eq("partial")
    end
  end

  describe "#as_json" do
    let(:representer_klass) do
      Class.new(TextRepresenter::Base) do
        attribute :foo
        attribute :children
        attribute :neighbor
      end
    end

    it "returns a hash of attributes" do
      representer = representer_klass.new
      child = representer_klass.new
      neighbor = representer_klass.new
      child.foo = "partial"
      representer.foo = "bar value"
      representer.children = [child]
      representer.neighbor = neighbor
      expect(representer.as_json).to eq({
        "foo" => "bar value",
        "neighbor" => {},
        "children" => [
          { "foo" => "partial" }
        ]
      })
    end
  end

  describe "#apply" do
    let(:representer_klass) do
      Class.new(TextRepresenter::Base)
    end

    it "sets the context, calls represent, and resets the context" do
      representer = representer_klass.new
      context = instance_double(Object)
      allow(representer).to receive(:template) do
        expect(representer.context).to eq(context)
      end
      representer.apply(context)
      expect(representer).to have_received(:template)
      expect(representer.context).to be_nil
    end
  end

  describe "#parse" do
    context "with simple literal" do
      let(:representer_klass) do
        Class.new(TextRepresenter::Base) do
          def template
            literal "foo"
          end
        end
      end

      it "parses literal text" do
        text = "foo"
        representer = representer_klass.new
        expect { representer.parse(text) }.not_to raise_error
      end

      it "raises on unmatched literal text" do
        text = "bar"
        representer = representer_klass.new
        expect { representer.parse(text) }.to raise_error(TextRepresenter::UnmatchedPatternError)
      end

      it "raises on extra text when exact: true" do
        text = "foo extra"
        representer = representer_klass.new
        expect { representer.parse(text, exact: true) }.to raise_error(TextRepresenter::UnmatchedPatternError)
      end

      it "parses longer text when exact: false" do
        text = "foo extra"
        representer = representer_klass.new
        expect { representer.parse(text, exact: false) }.not_to raise_error
      end
    end

    context "with variable pattern" do
      let(:representer_klass) do
        Class.new(TextRepresenter::Base) do
          attribute :magic
          attribute :lines
          attribute :has_data
          attribute :data

          def template
            partial :magic, self.class.magic_class, quantity: "?"
            partial :lines, self.class.line_class, quantity: "+"
            optional :has_data do
              literal "__END__\n"
              token :data, /.*/m
            end
          end

          def self.magic_class
            @magic_class ||= Class.new(TextRepresenter::Base) do
              attribute :space_before
              attribute :space_after
              def template
                line do
                  literal "#"
                  token :space_before, / +/
                  literal "frozen_string_literal:"
                  token :space_after, / +/
                  literal "true"
                end
              end
            end
          end

          def self.line_class
            @line_class ||= Class.new(TextRepresenter::Base) do
              attribute :comment
              attribute :expression
              attribute :string
              def template
                absence do
                  literal "__END__\n"
                end

                line do
                  partial :expression, self.class.expression_class, quantity: "?"
                  partial :string, self.class.string_class, quantity: "?"
                  partial :comment, self.class.comment_class, quantity: "?"
                end
              end

              def self.expression_class
                @expression_class ||= Class.new(TextRepresenter::Base) do
                  attribute :left
                  attribute :operator
                  attribute :right
                  def template
                    partial :left, self.class.number_class
                    token :space_before_operator, / */
                    token :operator, %r{[+\-*/]}
                    token :space_after_operator, / */
                    partial :right, self.class.number_class
                  end

                  def self.number_class
                    @number_class ||= Class.new(TextRepresenter::Base) do
                      attribute :value
                      def template
                        token :value, /\d+/, to: :to_i
                      end
                    end
                  end
                end
              end

              def self.string_class
                @string_class ||= Class.new(TextRepresenter::Base) do
                  attribute :content
                  def template
                    token :quote, /['"]/
                    token :content, /[^'"]*/
                    same_as :quote
                  end
                end
              end

              def self.comment_class
                @comment_class ||= Class.new(TextRepresenter::Base) do
                  attribute :content
                  def template
                    token :space_before, / */
                    literal "#"
                    token :content, /.*/
                  end
                end
              end
            end
          end
        end
      end

      it "parses optional partial patterns" do
        text = "# frozen_string_literal: true\n\n"
        representer = representer_klass.new
        expect { representer.parse(text) }.not_to raise_error
        expect(representer.magic.space_before).to eq(" ")
        expect(representer.magic.space_after).to eq(" ")
        expect(representer.lines.map(&:comment)).to eq([nil])
      end

      it "rewinds on failed partial match for optional patterns" do
        text = "# This is not frozen_string_literal\n"
        representer = representer_klass.new
        expect { representer.parse(text) }.not_to raise_error
        expect(representer.magic).to be_nil
        expect(representer.lines.map { |line| line.comment&.content }).to eq([" This is not frozen_string_literal"])
      end

      it "accepts quantity '?' and denies patterns" do
        text = "# some line\n__END__\nsome data"
        representer = representer_klass.new
        expect { representer.parse(text) }.not_to raise_error
        expect(representer.lines.map { |line| line.comment&.content }).to eq([" some line"])
        expect(representer.has_data).to be(true)
        expect(representer.data).to eq("some data")
      end

      it "accepts partial patterns without quantity" do
        text = "1 + 2\n"
        representer = representer_klass.new
        expect { representer.parse(text) }.not_to raise_error
        expect(representer.lines.first.expression.left.value).to eq(1)
        expect(representer.lines.first.expression.operator).to eq("+")
        expect(representer.lines.first.expression.right.value).to eq(2)
      end

      it "accepts same_as patterns" do
        text = "'hello'\n"
        representer = representer_klass.new
        expect { representer.parse(text) }.not_to raise_error
        expect(representer.lines.first.string.content).to eq("hello")
      end

      it "raises on unmatched patterns" do
        text = "'hello\"\n"
        representer = representer_klass.new
        expect { representer.parse(text) }.to raise_error(TextRepresenter::UnmatchedPatternError)
      end
    end

    context "with unsupported expose types" do
      let(:representer_klass) do
        Class.new(TextRepresenter::Base) do
          def template
            expose :foobar, :buz
          end
        end
      end

      it "raises on unsupported expose types" do
        representer = representer_klass.new
        expect { representer.parse("anything") }.to raise_error(TextRepresenter::FatalError, /Unknown expose type: foobar/)
      end
    end
  end

  context "with unsupported quantity for partial patterns" do
    let(:representer_klass) do
      Class.new(TextRepresenter::Base) do
        def template
          partial :foo, self.class.partial_class, quantity: "*"
        end

        def self.partial_class
          @partial_class ||= Class.new(TextRepresenter::Base) do
            def template; end
          end
        end
      end
    end

    it "raises on unsupported quantity" do
      representer = representer_klass.new
      expect { representer.parse("anything") }.to raise_error(NotImplementedError, /Unsupported quantity: \*/)
    end
  end

  describe "#to_s" do
    context "with simple literal" do
      let(:representer_klass) do
        Class.new(TextRepresenter::Base) do
          def template
            literal "foo"
          end
        end
      end

      it "represents literal text" do
        representer = representer_klass.new
        expect(representer.to_s).to eq("foo")
      end
    end

    context "with variable pattern" do
      let(:representer_klass) do
        Class.new(TextRepresenter::Base) do
          attribute :has_comments
          attribute :comments
          attribute :header
          attribute :tag
          attribute :text
          def template
            partial :header, self.class.header_class, quantity: "?"
            line do
              literal "<"
              partial :tag, self.class.tag_class
              literal ">"
            end
            line do
              token :text, /[^<>\n]+/
            end
            optional :has_comments do
              partial :comments, self.class.comment_class, quantity: "+"
            end
            line do
              literal "</"
              same_as :tag
              literal ">"
            end
          end

          def self.header_class
            @header_class ||= Class.new(TextRepresenter::Base) do
              attribute :doctype
              def template
                line do
                  literal "<!DOCTYPE "
                  token :doctype, /\w+/
                  literal ">"
                end
              end
            end
          end

          def self.tag_class
            @tag_class ||= Class.new(TextRepresenter::Base) do
              attribute :name
              def template
                token :name, /\w+/
              end
            end
          end

          def self.comment_class
            @comment_class ||= Class.new(TextRepresenter::Base) do
              attribute :content
              def template
                line do
                  literal "<!--"
                  token :content, /[^-]+/
                  literal "-->"
                end
              end
            end
          end
        end
      end

      it "represents text with patterns" do
        representer = representer_klass.new
        tag_representer = representer_klass.tag_class.new
        tag_representer.name = "div"
        representer.tag = tag_representer
        representer.text = "Hello, world!"
        expect(representer.to_s).to eq("<div>\nHello, world!\n</div>\n")
      end

      it "represents optional header and comments" do
        representer = representer_klass.new
        header_representer = representer_klass.header_class.new
        header_representer.doctype = "html"
        representer.header = header_representer

        tag_representer = representer_klass.tag_class.new
        tag_representer.name = "div"
        representer.tag = tag_representer
        representer.text = "Hello, world!"

        comment1 = representer_klass.comment_class.new
        comment1.content = "This is a comment"
        comment2 = representer_klass.comment_class.new
        comment2.content = "This is another comment"
        representer.has_comments = true
        representer.comments = [comment1, comment2]

        expect(representer.to_s).to eq("<!DOCTYPE html>\n<div>\nHello, world!\n<!--This is a comment-->\n<!--This is another comment-->\n</div>\n")
      end
    end

    context "with unsupported expose types" do
      let(:representer_klass) do
        Class.new(TextRepresenter::Base) do
          def template
            expose :foobar, :buz
          end
        end
      end

      it "raises on unsupported expose types" do
        representer = representer_klass.new
        expect { representer.to_s }.to raise_error(TextRepresenter::FatalError, /Unknown expose type: foobar/)
      end
    end

    context "with unexpected partial" do
      let(:representer_klass) do
        Class.new(TextRepresenter::Base) do
          def template
            partial :missing, self.class.missing_class
          end

          def self.missing_class
            @missing_class ||= Class.new(TextRepresenter::Base) do
              def template; end
            end
          end
        end
      end

      it "raises on missing attribute" do
        representer = representer_klass.new
        expect { representer.to_s }.to raise_error(TextRepresenter::FatalError, /Expected missing to be a Base or an Array of Base, got NilClas/)
      end
    end
  end
end
