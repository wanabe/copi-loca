import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { max: Number, order: String }

  connect() {
    // default to 5 if no value provided
    this.maxValue = this.hasMaxValue ? this.maxValue : 5
    // default order: 'append' (new items appended to end). use 'prepend' when new items are added to start.
    this.orderValue = this.hasOrderValue ? this.orderValue : 'append'
    this.observer = new MutationObserver(() => this.trim())
    this.observer.observe(this.element, { childList: true })
    this.trim()
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  trim() {
    const max = this.hasMaxValue ? this.maxValue : 5
    const order = this.hasOrderValue ? this.orderValue : 'append'
    while (this.element.children.length > max) {
      if (order === 'prepend') {
        // new items at start -> remove last
        this.element.removeChild(this.element.lastElementChild)
      } else {
        // new items at end -> remove first
        this.element.removeChild(this.element.firstElementChild)
      }
    }
  }
}
