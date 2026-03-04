# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Sessions::JobStatusComponent do
  it "renders running status" do
    render described_class.new(job_status: :running)
    expect(rendered).to include("sessions-job-status__spinner")
  end
end
