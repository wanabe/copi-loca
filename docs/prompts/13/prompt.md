---
name: create_new_controller
description: Create new controller
---
I would like you to create a new Memo controller.
- The only action is index.
- There are no models to handle.
- It has a feature to record multiple short sentences, like a microblog.
- The main purpose is for offline memos.
  - Therefore, it must be designed not only for DB persistence but also to avoid all server communication.
  - Data is saved in localstorage or indexed db.
- Please refer to the surrounding files for the coding style of controllers and views.
- Please write Javascript concisely and securely using Stimulus.
- Please make sure to fetch and cache the necessary files for offline operation using a service worker.