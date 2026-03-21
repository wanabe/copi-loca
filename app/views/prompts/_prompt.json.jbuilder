# frozen_string_literal: true
# rbs_inline: enabled

json.extract! prompt, :id, :text
json.url prompt_url(prompt, format: :json)
