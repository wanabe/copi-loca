
class RunOperationJob < ApplicationJob
  RENDER_INTERVAL = 0.1.seconds
  READ_LIMIT = 1024

  queue_as :default

  def perform(operation_id)
    operation = Operation.find(operation_id)
    output = ""
    @render_at = Time.current
    status = operation.run do |reader|
      loop do
        broadcast(operation, output, "running")
        partial = reader.readpartial(READ_LIMIT)
        output += partial
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
    Turbo::StreamsChannel.broadcast_replace_to(
      operation,
      target: "operation-result",
      partial: "operations/run",
      locals: {  operation: operation, output: output, status: status }
    )
  end
end
