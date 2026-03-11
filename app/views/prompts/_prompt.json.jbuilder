# frozen_string_literal: true

json.extract! prompt, :id, :text
json.url prompt_url(prompt, format: :json)
