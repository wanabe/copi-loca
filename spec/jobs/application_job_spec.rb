# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationJob do
  describe "inheritance" do
    it "inherits from ActiveJob::Base" do
      expect(described_class < ActiveJob::Base).to be true
    end
  end

  describe "retry_on deadlock" do
    it "has commented retry_on for ActiveRecord::Deadlocked" do
      source = Rails.root.join("app/jobs/application_job.rb").read
      expect(source).to include("retry_on ActiveRecord::Deadlocked")
    end
  end

  describe "discard_on deserialization error" do
    it "has commented discard_on for ActiveJob::DeserializationError" do
      source = Rails.root.join("app/jobs/application_job.rb").read
      expect(source).to include("discard_on ActiveJob::DeserializationError")
    end
  end
end
