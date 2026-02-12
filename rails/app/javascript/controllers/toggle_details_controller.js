import { Controller } from "@hotwired/stimulus";

// Stimulus controller to toggle <details> open/close when content is clicked
export default class extends Controller {
  static targets = ["content"];

  toggle(event) {
    // Prevent toggling if click is on summary
    if (event.target.closest("summary")) return;
    const details = this.element.querySelector("details");
    if (details) details.open = !details.open;
  }
}
