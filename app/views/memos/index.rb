# frozen_string_literal: true

class Views::Memos::Index < Views::Base
  def view_template
    h1(class: "text-2xl font-bold mb-4") { "Memo" }

    div(class: "mb-4", data: { controller: "memo" }) do
      form(data: { action: "submit->memo#saveMemo" }) do
        input(type: "text", id: "memo_input", maxlength: "140", placeholder: "Write a memo...", autocomplete: "off", data: { memo_target: "input" },
          class: "border px-2 py-1 mr-2")
        button(type: "submit", class: "bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600") { "Add" }
      end

      ul(data: { memo_target: "list" }, class: "space-y-2 mt-4")

      template(data: { memo_target: "template" }) do
        li(class: "flex justify-between items-center border-b pb-2") do
          div(class: "flex flex-col") do
            span(class: "break-all text-lg", data: { memo_target: "text" })
            span(class: "text-xs text-gray-400", data: { memo_target: "time" })
          end
          button(
            class: "bg-red-500 text-white px-2 py-1 rounded text-sm hover:bg-red-600 ml-4",
            data: { action: "click->memo#deleteMemo" }
          ) { "Delete" }
        end
      end
    end
  end
end
