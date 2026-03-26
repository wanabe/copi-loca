---
name: add_new_action
description: Add new action
---
I would like you to create the Git::HeadsController#create action.

This action is called from the Git::HeadsController#new page.
The action performs a `git commit` operation via `Git.call!`.
On the screen, there should be a textarea for entering the commit message and a button for committing. When the button is pressed, the commit is performed.
After the operation is complete, please redirect to the Git::HeadsController#new page.