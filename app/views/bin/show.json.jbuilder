# frozen_string_literal: true

json.partial! "bin/bin", bin: @bin
json.set! :status, @status
json.set! :output, @output
