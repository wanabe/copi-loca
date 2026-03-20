---
name: create_new_controller
description: Create new controller
---
I would like you to create new controllers, Git and Git::Grep.
- Git
  - it has only index action.
  - The index action is just a collection of links, containing only a link to Git::Grep#index.
- Git::Grep
  - it has only index action.
  - The index page has a branch select box, a pattern text field, a files text area, and a pre tag to display grep results.
  - The branch select box allows selection of an empty string, local git branches, and remote git branches.
  - If the pattern parameter is not provided, the grep result is empty.
  - If the pattern parameter is provided, the controller executes git grep and passes the result to the view.
  - 