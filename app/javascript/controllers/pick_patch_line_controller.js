import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  handleClick(event) {
    const target = event.target.closest("span.token.prefix.inserted, span.token.prefix.deleted");
    if (!target) return;

    const code = target.closest("code");
    if (!code) return;

    const all = Array.from(code.querySelectorAll("span.token.prefix"));
    const index = all.indexOf(target);
    if (index === -1) return;

    const pre = code.closest("pre[data-patch-path][data-patch-for][data-action-name]");
    if (!pre) return;

    this.submitPatch({
      method: "post",
      action: `/git/refs/HEAD/-/${pre.dataset.actionName}`,
      path: pre.dataset.patchPath,
      hunk: code.innerText,
      lineno: index + 1,
      for: pre.dataset.patchFor || "new",
    });
  }

  submitPatch({ method, action, ...fields }) {
    const form = Object.assign(document.createElement("form"), { method, action });
    for (const [name, value] of Object.entries(fields)) {
      form.appendChild(Object.assign(document.createElement("input"), {
        type: "hidden", name, value,
      }));
    }
    document.body.appendChild(form);
    form.requestSubmit();
    form.remove();
  }
}
