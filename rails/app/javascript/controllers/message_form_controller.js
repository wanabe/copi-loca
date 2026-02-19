import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messageContent"]

  connect() {
    window.addEventListener('copyMessage', this.handleCopyMessage.bind(this));
  }

  handleCopyMessage(event) {
    if (this.hasMessageContentTarget) {
      this.messageContentTarget.value = event.detail.content;
      this.messageContentTarget.focus();
      // Auto-resize textarea
      const textarea = this.messageContentTarget;
      textarea.style.height = textarea.scrollHeight + 'px';
    }
  }
}
