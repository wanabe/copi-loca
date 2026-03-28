# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Entries::ShowTree < Views::Base
  # @rbs @ref: String
  # @rbs @path: String
  # @rbs @entries: Array[Git::LsTree::Entry]
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]

  # @rbs ref: String
  # @rbs path: String
  # @rbs entries: Array[Git::LsTree::Entry]
  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs return: void
  def initialize(ref:, path:, entries:, flash: {}, breadcrumbs: [])
    super(flash: flash, breadcrumbs: breadcrumbs)
    @ref = ref
    @path = path
    @entries = entries
  end

  # @rbs return: void
  def body_template
    content_for :title, "Git Entry: #{@path}"
    h1(class: "text-2xl font-bold mb-4") { "Tree #{@ref}:#{@path}" }
    dir = @path
    raise "Invalid path" unless dir

    ul do
      @entries.each do |entry|
        type = entry.type
        path = entry.path
        raise "Invalid entry type" if !type || !path

        name = File.basename(path)
        li do
          case type
          when "tree"
            span(class: "mr-1") do
              "\u{1F4C1} "
            end
            link_to name, git_ref_entry_path(ref: @ref, path: path), class: "text-blue-600 hover:underline"
          when "blob"
            span(class: "mr-1") do
              "\u{1F4C4} "
            end
            link_to name, git_ref_entry_path(ref: @ref, path: path, raw: "false"), class: "text-gray-600 hover:underline"
            link_to " (raw)", git_ref_entry_path(ref: @ref, path: path), class: "text-gray-400 hover:underline"
          else
            span(class: "mr-1") do
              "\u{2753} "
            end
            plain name
          end
        end
      end
    end
  end
end
