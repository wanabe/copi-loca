import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="pick-patch-line"
export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this.handleClick.bind(this));
  }

  disconnect() {
    this.element.removeEventListener("click", this.handleClick.bind(this));
  }

  async handleClick(event) {
    // Find the closest span.token.prefix
    const target = event.target.closest("span.token.prefix.inserted, span.token.prefix.deleted");
    if (!target) return;
    // Find code element
    const code = target.closest("code");
    if (!code) return;
    // Find all span.token.prefix in this code element
    const all = Array.from(code.querySelectorAll("span.token.prefix"));
    const index = all.indexOf(target);
    if (index === -1) return;

    // Get hunk from code.innerText
    const hunk = code.innerText;
    // Get path and for_param from pre[data-patch-path][data-patch-for]
    const pre = code.closest("pre[data-patch-path][data-patch-for][data-action]");
    if (!pre) return;
    const path = pre.dataset.patchPath;
    const forParam = pre.dataset.patchFor || 'new';
    const action = pre.dataset.action;
    // Compose params
    const params = new URLSearchParams({ path, hunk, lineno: index, for: forParam });
    // POST to Rails
    const resp = await fetch(`/git/refs/HEAD/-/${action}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'X-CSRF-Token': this.getCsrfToken()
      },
      body: params.toString(),
      redirect: 'follow',
      credentials: 'same-origin',
    });

    if (resp.redirected) {
      Turbo.visit(resp.url);
    } else if (resp.status !== 200) {
      alert('Error performing action');
    }
  }

  getCsrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta && meta.getAttribute('content');
  }
}
