# frozen_string_literal: true

json.extract! prompt, :id, :created_at, :updated_at
json.url prompt_url(prompt, format: :json)
