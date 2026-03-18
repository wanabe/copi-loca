import { Controller } from "@hotwired/stimulus";

// MemoController: Handles offline memos using localStorage
export default class extends Controller {
  static targets = ["input", "list", "template"];

  connect() {
    this.loadMemos();
  }

  loadMemos() {
    const memos = JSON.parse(localStorage.getItem("memos") || "[]");
    this.listTarget.innerHTML = "";
    memos.forEach(m => this.addMemo(m));
  }

  saveMemo(event) {
    event.preventDefault();
    const text = this.inputTarget.value.trim();
    if (!text) return;

    const newMemo = { text, ts: Date.now() };
    const memos = JSON.parse(localStorage.getItem("memos") || "[]");
    memos.push(newMemo);
    localStorage.setItem("memos", JSON.stringify(memos));

    this.addMemo(newMemo);
    this.inputTarget.value = "";
  }

  addMemo(memo) {
    const clone = this.templateTarget.content.cloneNode(true);
    const li = clone.querySelector("li");
    clone.querySelector("[data-memo-target='text']").textContent = memo.text;
    const date = new Date(memo.ts);
    const timeString = date.toLocaleString(undefined, {
      year: 'numeric', month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit', second: '2-digit'
    });
    clone.querySelector("[data-memo-target='time']").textContent = timeString;
    li.dataset.ts = memo.ts;

    this.listTarget.prepend(clone);
  }

  deleteMemo(event) {
    const li = event.target.closest("li");
    const ts = parseInt(li.dataset.ts, 10);

    let memos = JSON.parse(localStorage.getItem("memos") || "[]");
    memos = memos.filter(m => m.ts !== ts);
    localStorage.setItem("memos", JSON.stringify(memos));

    li.remove();
  }
}