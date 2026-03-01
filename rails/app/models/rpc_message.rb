# frozen_string_literal: true

class RpcMessage < ApplicationRecord
  belongs_to :session, optional: false
  has_one :message, required: false, dependent: :destroy
  has_one :event, required: false, dependent: :destroy

  enum :direction, { outgoing: 1, incoming: 2 }
  enum :message_type, { request: 1, response: 2, notification: 3 }

  validates :direction, presence: true
  validates :message_type, presence: true
  validates :rpc_id, presence: true, if: -> { request? || response? }
  validates :rpc_id, absence: true, if: -> { notification? }
  validates :method, presence: true, if: -> { request? || notification? }
  validates :params, exclusion: [nil], if: -> { request? || notification? }
  validates :params, inclusion: [nil], if: -> { response? }
  validates :result, exclusion: [nil], if: -> { response? && error.nil? }
  validates :result, inclusion: [nil], if: -> { error.present? || request? || notification? }
  validates :error, exclusion: [nil], if: -> { response? && result.nil? }
  validates :error, inclusion: [nil], if: -> { result.present? || request? || notification? }

  before_validation :set_message_type
  before_save :set_method_for_response, if: -> { response? && method.nil? }

  def handle
    return unless incoming?
    return if method != "session.event"

    event_data = params["event"]
    return unless event_data

    parent_event = session.events.find_by(event_id: event_data["parentId"]) if event_data["parentId"]
    create_event!(
      event_id: event_data["id"],
      session: session,
      event_type: event_data["type"],
      data: event_data["data"],
      timestamp: event_data["timestamp"],
      parent_event: parent_event,
      ephemeral: event_data["ephemeral"] || false
    ).handle
  end

  private

  def set_message_type
    if method.present? && !params.nil? && result.nil? && error.nil?
      self.message_type = if rpc_id.present?
                            :request
                          else
                            :notification
                          end
    elsif rpc_id.present? && params.nil? && (result.present? || error.present?)
      self.message_type = :response
    end
  end

  def set_method_for_response
    request = session.rpc_messages.find_by(rpc_id: rpc_id, message_type: :request)
    return unless request

    self.method = request.method
  end
end
