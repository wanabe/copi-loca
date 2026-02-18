class Operation < ApplicationRecord
  validates :command, presence: true
  validates :directory, presence: true

  enum :execution_timing, { manual: 1, immediate: 2, background: 3 }

  def run
    unless block_given?
      output = ""
      status = run { |reader| output = reader.read }
      return output, status
    end

    status = nil
    Dir.chdir(directory) do
      reader, writer = IO.pipe
      pid = Process.spawn(command, out: writer, err: writer)
      writer.close
      yield reader
      _, process_status = Process.wait2(pid)
      status = process_status.exitstatus
      reader.close
    end
    status
  end
end
