import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.element.showModal) {
      this.element.showModal();
    }
  }
}
