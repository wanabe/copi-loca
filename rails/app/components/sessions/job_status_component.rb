# frozen_string_literal: true

module Components
  module Sessions
    class JobStatusComponent < Components::Base
      def initialize(job_status:)
        @job_status = job_status
      end

      def view_template
        div(id: "job-status") do
          if @job_status == :running
            div(id: "job-status-indicator", class: "sessions-job-status__indicator") do
              span(class: "spinner sessions-job-status__spinner")
            end
          end
        end
      end
    end
  end
end
