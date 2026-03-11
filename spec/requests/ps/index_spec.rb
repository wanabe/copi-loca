# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /ps" do
  it "renders the index view with process lines" do
    fake_lines = [
      "UID        PID  PPID  C STIME TTY          TIME CMD",
      "root         1     0  0 Mar11 ?        00:00:01 init",
      "user      1234     1  0 Mar11 ?        00:00:00 bash"
    ]
    allow(PsController).to receive(:new).and_wrap_original do |method, *args, &block|
      instance = method.call(*args, &block)
      allow(instance).to receive(:`).with("ps -ef").and_return(fake_lines.join("\n"))
      instance
    end

    get ps_path

    expect(controller).to be_a(PsController)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("UID        PID  PPID  C STIME TTY          TIME CMD")
    expect(response.body).to include("root         1     0  0 Mar11 ?        00:00:01 init")
    expect(response.body).to include("user      1234     1  0 Mar11 ?        00:00:00 bash")
  end
end
