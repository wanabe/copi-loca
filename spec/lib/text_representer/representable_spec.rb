# frozen_string_literal: true

require "rails_helper"
require "text_representer"

RSpec.describe TextRepresenter::Representable do
  let(:name_address_class) do
    Class.new do
      include TextRepresenter::Representable

      attr_accessor :has_display_name, :display_name, :address

      def initialize(has_display_name: nil, display_name: nil, address: nil)
        @has_display_name = has_display_name
        @display_name = display_name
        @address = address
      end

      def template
        optional :has_display_name do
          token :display_name, /[0-9a-zA-Z ]*[0-9a-zA-Z]/
          literal " "
        end
        absence do
          literal " "
        end
        literal "<"
        token :address, /[^>]+/
        literal ">"
      end
    end
  end

  let(:mail_header_class) do
    name_address_class = self.name_address_class
    Class.new do
      define_method(:name_address_class) { name_address_class }

      include TextRepresenter::Representable

      attr_accessor :from, :tos, :subject, :colon

      def template
        line do
          literal "From"
          token :colon, /:/
          literal " "
          partial :from, name_address_class
        end
        line do
          literal "To"
          same_as :colon
          literal " "
          partial :tos, name_address_class, quantity: "+", separator: -> { literal ", " }
        end
        line do
          literal "Subject"
          same_as :colon
          literal " "
          token :subject, /.+/
        end
      end
    end
  end

  let(:text) { "From: <alice@example.com>\nTo: Bob <bob@example.com>, Carol <carol@example.com>\nSubject: Hello\n" }
  let(:expected_attrs) do
    {
      from: { has_display_name: false, display_name: nil, address: "alice@example.com" },
      tos: [
        { has_display_name: true, display_name: "Bob", address: "bob@example.com" },
        { has_display_name: true, display_name: "Carol", address: "carol@example.com" }
      ],
      subject: "Hello"
    }
  end

  describe "#parse" do
    it "parses mail header text into attributes" do
      header = mail_header_class.new.parse(text)
      expect(header.from.has_display_name).to eq expected_attrs[:from][:has_display_name]
      expect(header.from.display_name).to eq expected_attrs[:from][:display_name]
      expect(header.from.address).to eq expected_attrs[:from][:address]
      expect(header.tos[0].has_display_name).to eq expected_attrs[:tos][0][:has_display_name]
      expect(header.tos[0].display_name).to eq expected_attrs[:tos][0][:display_name]
      expect(header.tos[0].address).to eq expected_attrs[:tos][0][:address]
      expect(header.tos[1].has_display_name).to eq expected_attrs[:tos][1][:has_display_name]
      expect(header.tos[1].display_name).to eq expected_attrs[:tos][1][:display_name]
      expect(header.tos[1].address).to eq expected_attrs[:tos][1][:address]
      expect(header.subject).to eq expected_attrs[:subject]
    end

    it "raises an error if the absence pattern is present" do
      invalid_text = "From: Alice  <"
      expect { mail_header_class.new.parse(invalid_text) }.to raise_error(TextRepresenter::UnmatchedPatternError, /Expected token to not match/)
    end

    context "with invalid expose" do
      let(:invalid_class) do
        Class.new do
          include TextRepresenter::Representable

          def template
            expose :literal, "foo"
            expose :bar
          end
        end
      end

      it "raises an error" do
        expect { invalid_class.new.parse("foo") }.to raise_error(TextRepresenter::FatalError, /Unknown expose type: bar/)
      end
    end

    context "with unsupported quantity" do
      let(:invalid_class) do
        Class.new do
          include TextRepresenter::Representable

          def template
            expose :partial, :foo, nil, quantity: "?"
          end
        end
      end

      it "raises an error" do
        expect { invalid_class.new.parse("foo") }.to raise_error(NotImplementedError, /Unsupported quantity: \?/)
      end
    end
  end

  describe "#render" do
    it 'renders mail header with multiple to (quantity: "+")' do
      header = mail_header_class.new
      header.colon = ":"
      header.from = name_address_class.new(**expected_attrs[:from])
      header.tos = [
        name_address_class.new(has_display_name: true, display_name: "Bob", address: "bob@example.com"),
        name_address_class.new(has_display_name: true, display_name: "Carol", address: "carol@example.com")
      ]
      header.subject = expected_attrs[:subject]
      expect(header.render).to include("To: Bob <bob@example.com>, Carol <carol@example.com>")
    end

    it "renders attributes into mail header text" do
      header = mail_header_class.new
      header.colon = ":"
      header.from = name_address_class.new(**expected_attrs[:from])
      header.tos = [
        name_address_class.new(**expected_attrs[:tos][0]),
        name_address_class.new(**expected_attrs[:tos][1])
      ]
      header.subject = expected_attrs[:subject]
      expect(header.render).to eq text
    end

    context "with unsupported partial value" do
      let(:invalid_class) do
        Class.new do
          include TextRepresenter::Representable

          def foo
            "unsupported value"
          end

          def template
            partial :foo, nil
          end
        end
      end

      it "raises an error" do
        expect do
          invalid_class.new.render
        end.to raise_error(TextRepresenter::FatalError, /Expected foo to be a Representable or an Array of Representable, got String/)
      end
    end
  end
end
