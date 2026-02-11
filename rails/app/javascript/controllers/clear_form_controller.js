import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.submitEnd = this.submitEnd.bind(this)
    this.element.addEventListener("turbo:submit-end", this.submitEnd)
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.submitEnd)
  }

  submitEnd(event) {
    // On successful submission Turbo sets event.detail.success to true
    if (event.detail && event.detail.success) {
      // Reset the form fields
      this.element.reset()
      // Focus the textarea for convenience
      const textarea = this.element.querySelector("textarea")
      if (textarea) textarea.focus()
    }
  }
}
