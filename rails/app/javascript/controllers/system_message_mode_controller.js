import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="system-message-mode"
export default class extends Controller {
  static targets = ["mode", "message"]

  connect() {
    this.toggleMessage()
  }

  toggleMessage() {
    if (this.modeTarget.value === "default") {
      this.messageTarget.disabled = true
    } else {
      this.messageTarget.disabled = false
    }
  }
}
