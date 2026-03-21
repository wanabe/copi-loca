# frozen_string_literal: true
# rbs_inline: enabled

json.partial! "bin/bin", bin: @bin
json.set! :status, @status
json.set! :output, @output
