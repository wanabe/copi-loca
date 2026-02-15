class Operation < ApplicationRecord
  def run
    output = ''
    status = nil
    Dir.chdir(directory) do
      reader, writer = IO.pipe
      pid = Process.spawn(command, out: writer, err: writer)
      writer.close
      output = reader.read
      _, process_status = Process.wait2(pid)
      status = process_status.exitstatus
      reader.close
    end
    [output, status]
  end
end
