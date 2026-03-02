# frozen_string_literal: true

class Operation < ApplicationRecord
  validates :command, presence: true
  validates :directory, presence: true

  enum :execution_timing, { manual: 1, immediate: 2, background: 3 }

  def run(&)
    unless block_given?
      output = ""
      status = run { |reader| output = reader.read }
      return output, status
    end

    Dir.chdir(directory) do
      Bundler.with_unbundled_env do
        IO.popen(command, &)
      end
    end
    Process.last_status.exitstatus
  end
end
