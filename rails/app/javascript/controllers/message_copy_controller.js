import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  copy(event) {
    event.preventDefault();
    const content = event.currentTarget.dataset.content;
    window.dispatchEvent(new CustomEvent('copyMessage', { detail: { content } }));
    const dialog = event.currentTarget.closest('dialog');
    if (dialog && dialog.close) dialog.close();
  }
}
