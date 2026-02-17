class Event < ApplicationRecord
  belongs_to :session, optional: false
  belongs_to :rpc_message, optional: false
  belongs_to :parent_event, class_name: "Event", optional: true, inverse_of: :child_events
  has_many :child_events, class_name: "Event", foreign_key: "parent_event_id", dependent: :nullify, inverse_of: :parent_event

  def handle
    case event_type
    when "assistant.message"
      handle_assistant_message
    when "session.usage_info"
      handle_session_usage_info
    end
  end

  private
    def handle_assistant_message
      content = data["content"]
      return if content.blank?
      rpc_message.create_message!(
        session: session,
        direction: :incoming,
        content: content
      )
    end

    def handle_session_usage_info
      values = {
        token_limit: data["tokenLimit"],
        current_tokens: data["currentTokens"]
      }.compact
      session.update!(**values) if values.present?
    end
end
