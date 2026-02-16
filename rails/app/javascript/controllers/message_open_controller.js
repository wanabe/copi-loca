import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { open: Boolean }

  connect() {
    this.lastState = {};
    const items = this.element.querySelectorAll(".message-item");
    items.forEach(item => {
      const messageId = item.id;
      if (!messageId) return;
      const details = item.querySelector("details");
      if (!details) return;
      details.open = this.openValue;
      this.lastState[messageId] = details.open;
    });

    this.observer = new MutationObserver(() => {
      this.openDetailsIfNeeded();
    })
    this.observer.observe(this.element, { childList: true, subtree: true })
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  openDetailsIfNeeded() {
    const items = this.element.querySelectorAll(".message-item");
    let newState = {};
    items.forEach(item => {
      const messageId = item.id;
      if (!messageId) return;
      const details = item.querySelector("details");
      if (!details) return;
      if (this.lastState[messageId] === undefined) {
        newState[messageId] = this.openValue; // new item, set to openValue
      } else {
        newState[messageId] = this.lastState[messageId]; // existing item, keep last state
      }
      details.open = newState[messageId];
    });
    this.lastState = newState;
  }
}
