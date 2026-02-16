class Event < ApplicationRecord
  belongs_to :session, optional: false
  belongs_to :rpc_message, optional: false
  belongs_to :parent_event, class_name: "Event", optional: true, inverse_of: :child_events
  has_many :child_events, class_name: "Event", foreign_key: "parent_event_id", dependent: :nullify, inverse_of: :parent_event

  def handle
    return if event_type != "assistant.message"
    content = data["content"]
    return if content.blank?
    rpc_message.create_message!(
      session: session,
      direction: :incoming,
      content: content
    )
  end
end
