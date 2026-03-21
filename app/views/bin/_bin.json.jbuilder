# frozen_string_literal: true
# rbs_inline: enabled

json.extract! bin, :id
json.url bin_url(bin, format: :json)
