# frozen_string_literal: true
# rbs_inline: enabled

# @from: String
# @layout: String
# @rbs
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
end
