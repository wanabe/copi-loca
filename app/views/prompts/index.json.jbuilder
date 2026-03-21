# frozen_string_literal: true
# rbs_inline: enabled

json.array! @prompts, partial: "prompts/prompt", as: :prompt
