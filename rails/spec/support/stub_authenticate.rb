# frozen_string_literal: true

module StubAuthenticate
  def authenticate
    super if RSpec.current_example.metadata[:with_auth]
  end
end
