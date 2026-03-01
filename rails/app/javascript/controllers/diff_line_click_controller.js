import { Controller } from "@hotwired/stimulus";

// Usage: data-controller="diff-line-click"
// Attaches click event to each line in a <pre><code> diff block
export default class extends Controller {
  static targets = ["code"];

  connect() {
    this.decorateLines();
  }

  decorateLines() {
    if (!this.hasCodeTarget) return;
    const code = this.codeTarget;
    const checker = setInterval(() => {
      const lineElements = code.querySelectorAll('.token.coord');
      if (lineElements.length > 0) {
        clearInterval(checker);
        setTimeout(() => this.attachLineEvents(code), 100);
      }
    }, 100);
  }

  attachLineEvents(code) {
    const filePath = code.closest('[data-file-path]')?.dataset.filePath;
    const stageState = code.closest('[data-stage-state]')?.dataset.stageState;
    const lineElements = code.querySelectorAll('.token.line, .token.coord, .token.prefix');
    let offset = 0;
    lineElements.forEach((element, idx) => {
      const lineNumber = idx + 1 + offset;
      element.dataset.lineNumber = lineNumber;
      if (element.classList.contains('prefix')) {
        // Prefix mark "+" or "-" should listen click events but not count as line
        offset -= 1;
      }
      const parent = element.parentElement;
      if (!parent) return;
      const inDiff = parent.classList.contains('inserted') || parent.classList.contains('deleted');
      if (!inDiff) return;
      element.addEventListener('click', () => {
        if (!filePath || !stageState) return;
        if (stageState === 'staged') {
          this.unstageLine(filePath, lineNumber);
        } else if (stageState === 'unstaged') {
          this.stageLine(filePath, lineNumber);
        }
      });
    });
  }

  async stageLine(filePath, lineNumber) {
    const code = this.codeTarget;
    const amend = code.closest('[data-amend]')?.dataset.amend === 'true';
    const formData = new FormData();
    formData.append('file_path', filePath);
    formData.append('line_number', lineNumber);
    if (amend) formData.append('amend', 'true');
    const response = await fetch(code.dataset.stageUrl, {
      method: 'POST',
      headers: { 'X-CSRF-Token': this.getCsrfToken() },
      body: formData
    });
    if (response.redirected) {
      window._copiLocaScrollY = window.scrollY;
      Turbo.visit(response.url, { scroll: false });
      document.addEventListener('turbo:load', function restoreScroll() {
        window.scrollTo(0, window._copiLocaScrollY || 0);
        document.removeEventListener('turbo:load', restoreScroll);
      });
    } else {
      const text = await response.text();
      Turbo.renderStreamMessage(text);
    }
  }

  async unstageLine(filePath, lineNumber) {
    const code = this.codeTarget;
    const amend = code.closest('[data-amend]')?.dataset.amend === 'true';
    const formData = new FormData();
    formData.append('file_path', filePath);
    formData.append('line_number', lineNumber);
    if (amend) formData.append('amend', 'true');
    const response = await fetch(code.dataset.unstageUrl, {
      method: 'POST',
      headers: { 'X-CSRF-Token': this.getCsrfToken() },
      body: formData
    });
    if (response.redirected) {
      window._copiLocaScrollY = window.scrollY;
      Turbo.visit(response.url, { scroll: false });
      document.addEventListener('turbo:load', function restoreScroll() {
        window.scrollTo(0, window._copiLocaScrollY || 0);
        document.removeEventListener('turbo:load', restoreScroll);
      });
    } else {
      const text = await response.text();
      Turbo.renderStreamMessage(text);
    }
  }

  getCsrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta && meta.getAttribute('content');
  }
}
