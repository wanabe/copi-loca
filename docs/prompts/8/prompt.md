---
name: add_new_action
description: Add new action
---
I want to make it possible to call the stage and unstage actions of Git::HeadsController from the new screen.

These actions are triggered from the new screen of the Heads controller. When the icon is clicked, if the file is in the staged state, it will be unstaged; if it is in the unstaged state, it will be staged.
For example, if the icon of an unstaged file is clicked, the stage action will be executed for that file path.
Conversely, if the icon of a staged file is clicked, the unstage action will be executed for that file path.