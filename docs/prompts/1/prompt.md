---
name: english
description: Translate texts and characters to English.
---
- First,list files that have been changed or newly added.
  - To list changed files, you can combine the results of them:
    - `git --no-pager diff --name-only --cached`
    - `git --no-pager diff --name-only`
    - `git --no-pager ls-files --others --exclude-standard`
- Next, from the files listed above, check if there is at least one file containing non-ASCII characters.
  - To search for non-ASCII characters, you can use the command:
    - `git --no-pager grep --no-index -I "[^ -~]" -- <file1> <file2> ...`.
- If there are none, do nothing.
- If there is at least one, for one of the files containing non-ASCII characters, translate it into English if it is in a language other than English, and overwrite the file.
- If the content is not natural language but symbols or emojis, replace them with an appropriate English expression and overwrite the file.
- When translating, try to preserve the original meaning of the sentences as accurately as possible.
- If there is a target file, be sure to translate and overwrite the file before asking the user for confirmation. Confirmation is prohibited.
