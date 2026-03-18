Understood. Here is my approach:
1. Add a button to the Memos index view to trigger memo sync.
2. Update app/javascript/controllers/memo_controller.js to extract memos from local storage and send them to sync_local_memos via AJAX.
3. Ensure the sync_local_memos action in MemosController receives and processes the data.

I will start by reviewing the Memos index view and memo_controller.js, then implement the changes.

All required changes are complete:

- Added a "Sync Local Memos" button to the Memos index view.
- Implemented syncLocalMemos in memo_controller.js to extract memos from localStorage and send them to sync_local_memos via AJAX.
- The sync_local_memos action in MemosController already handles saving memos to docs/memos.json.

You can now sync local memos to the docs/ directory using the new button. Let me know if you need further adjustments!

