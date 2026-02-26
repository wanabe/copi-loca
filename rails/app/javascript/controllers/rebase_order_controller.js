import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row"]

  move(event) {
    const direction = parseInt(event.currentTarget.dataset.direction, 10);
    const row = event.currentTarget.closest(".rebase__row");
    const tbody = row.parentNode;
    const rows = Array.from(tbody.children);
    const idx = rows.indexOf(row);
    const targetIdx = idx + direction;
    if (targetIdx < 0 || targetIdx >= rows.length) return;
    if (direction === -1) {
      tbody.insertBefore(row, rows[targetIdx]);
    } else {
      tbody.insertBefore(rows[targetIdx], row);
    }
    row.classList.add('rebase__row--moved');
    // Remove the class right after reflow to trigger the animation
    setTimeout(() => row.classList.remove('rebase__row--moved'), 10);
    this.updateDisabledButtons();
  }

  connect() {
    if (!this.hasDisabledValue || this.disabledValue === "false") {
      this.updateDisabledButtons();
    }
  }

  updateDisabledButtons() {
    const tbody = this.element.querySelector('tbody');
    const rows = Array.from(tbody.children);
    rows.forEach((row, idx) => {
      const upBtn = row.querySelector('[data-direction="-1"]');
      const downBtn = row.querySelector('[data-direction="1"]');
      if (upBtn) upBtn.disabled = idx === 0;
      if (downBtn) downBtn.disabled = idx === rows.length - 1;
    });
  }
}
