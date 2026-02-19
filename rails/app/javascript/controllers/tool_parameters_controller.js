import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  add(event) {
    event.preventDefault();
    const content = this._template().replace(/NEW_RECORD/g, new Date().getTime());
    this.containerTarget.insertAdjacentHTML('beforeend', content);
  }

  remove(event) {
    event.preventDefault();
    const wrapper = event.target.closest('.nested-fields');
    if (wrapper.querySelector('input[type="hidden"][name*="_destroy"]')) {
      wrapper.querySelector('input[type="hidden"][name*="_destroy"]').value = 1;
      wrapper.style.display = 'none';
    } else {
      wrapper.remove();
    }
  }

  _template() {
    return document.getElementById('tool-parameter-template').innerHTML;
  }
}
