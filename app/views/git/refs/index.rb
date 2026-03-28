# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Refs::Index < Views::Base
  # @rbs @refs: Array[String]
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]

  # @rbs refs: Array[String]
  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs return: void
  def initialize(refs:, flash: {}, breadcrumbs: [])
    super(flash: flash, breadcrumbs: breadcrumbs)
    @refs = refs
  end

  # @rbs return: void
  def body_template
    h1(class: "text-2xl font-bold mb-4") { "Git Refs" }

    ul(class: "space-y-2") do
      @refs.each do |ref|
        li { link_to ref, git_ref_path(ref: ref), class: "text-blue-600 hover:underline" }
      end
    end
  end
end
