---
name: add_rbs_comments
description: Add RBS comments
---
Your task is to appropriately add RBS inline comments (type annotations) to Ruby code. Please follow the instructions below.

- First, run `bundle exec rubocop --only Style/RbsInline`.
- If no errors are displayed, your work is done. Thank you for your effort.
- If errors are displayed, resolve at least one of them.
- If there is insufficient type annotation for arguments, add the argument types.
- If there is insufficient type annotation for method return values, add the return types.
- If there is insufficient type annotation for instance variables, add the instance variable types.