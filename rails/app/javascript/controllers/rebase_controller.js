import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    const form = event.target.form || event.currentTarget.closest('form')
    if (form && typeof form.requestSubmit === "function") {
      form.requestSubmit()
    } else if (form) {
      form.submit()
    }
  }
}
