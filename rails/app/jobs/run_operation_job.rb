# frozen_string_literal: true

class RunOperationJob < ApplicationJob
  RENDER_INTERVAL = 0.5.seconds
  READ_LIMIT = 1024

  queue_as :default

  def perform(operation_id)
    operation = Operation.find(operation_id)
    output = +""
    @render_at = Time.current
    status = operation.run do |reader|
      loop do
        broadcast(operation, output, "running")
        partial = reader.readpartial(READ_LIMIT)
        output << partial
        output.force_encoding("UTF-8")
      rescue EOFError
        break
      end
    end
    sleep(RENDER_INTERVAL)
    broadcast(operation, output, status)
  end

  private

  def broadcast(operation, output, status)
    return if Time.current < @render_at

    @render_at = Time.current + RENDER_INTERVAL
    output = output.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    Turbo::StreamsChannel.broadcast_replace_to(
      operation,
      target: "operation-result",
      partial: "operations/run",
      locals: { operation: operation, output: output, status: status }
    )
  end
end
