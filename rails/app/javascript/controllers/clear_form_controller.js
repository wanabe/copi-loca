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
      // Explicitly reset the value and label of the file input
      const fileInput = this.element.querySelector('#file_upload');
      if (fileInput) {
        fileInput.value = '';
        fileInput.dispatchEvent(new Event('change'));
        const fileLabel = this.element.querySelector('#file_upload_label');
        if (fileLabel) fileLabel.innerText = 'File';
      }
      const cameraInput = this.element.querySelector('#camera_upload');
      if (cameraInput) {
        cameraInput.value = '';
        cameraInput.dispatchEvent(new Event('change'));
        const cameraLabel = this.element.querySelector('#camera_upload_label');
        if (cameraLabel) cameraLabel.innerText = 'Camera';
      }
      // Focus the textarea for convenience
      const textarea = this.element.querySelector("textarea")
      if (textarea) textarea.focus()
    }
  }
}
