class RpcMessage < ApplicationRecord
  belongs_to :session, optional: false

  enum :direction, { outgoing: 1, incoming: 2 }
  enum :message_type, { request: 1, response: 2, notification: 3 }

  validates :direction, presence: true
  validates :message_type, presence: true
  validates :rpc_id, presence: true, if: -> { request? || response? }
  validates :rpc_id, absence: true, if: -> { notification? }
  validates :method, presence: true, if: -> { request? || notification? }
  validates :params, exclusion: [ nil ], if: -> { request? || notification? }
  validates :params, inclusion: [ nil ], if: -> { response? }
  validates :result, exclusion: [ nil ], if: -> { response? && error.nil? }
  validates :result, inclusion: [ nil ], if: -> { error.present? || request? || notification? }
  validates :error, exclusion: [ nil ], if: -> { response? && result.nil? }
  validates :error, inclusion: [ nil ], if: -> { result.present? || request? || notification? }

  before_validation :set_message_type
  before_save :set_method_for_response, if: -> { response? && method.nil? }

  private
    def set_message_type
      if method.present? && params.present? && result.nil? && error.nil?
        if rpc_id.present?
          self.message_type = :request
        else
          self.message_type = :notification
        end
      elsif  rpc_id.present? && params.nil? && (result.present? || error.present?)
        self.message_type = :response
      end
    end

    def set_method_for_response
      request = session.rpc_messages.find_by(rpc_id: rpc_id, message_type: :request)
      if request
        self.method = request.method
      end
    end
end
