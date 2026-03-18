---
name: add_new_action
description: Add new action
---
I want an action in MemosController that copies local memos to the docs/ directory of the app.
- The sync_local_memos action has already been implemented.
- Please add a button to the Memos index view that calls the above sync_local_memos action.
- The data to be saved needs to be retrieved using JavaScript, so add the necessary functionality to app/javascript/controllers/memo_controller.js.
- Use the feature implemented in app/javascript/controllers/memo_controller.js to extract memos from local storage, retrieve the data, and pass it to sync_local_memos.