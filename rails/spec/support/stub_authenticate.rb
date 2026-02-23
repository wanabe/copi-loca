module StubAuthenticate
  def authenticate
    return super if RSpec.current_example.metadata[:with_auth]
  end
end
