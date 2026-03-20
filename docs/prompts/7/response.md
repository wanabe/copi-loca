Understood. I'll create two controllers: GitController and Git::GrepController, each with only an index action. Git#index will show a link to Git::Grep#index. Git::Grep#index will display a branch selector (empty, local, remote), a pattern field, a files textarea, and a <pre> for grep results. If a pattern is provided, it will run git grep and show the output; otherwise, the result is empty.

I'll generate the controllers, views, and update routes. I'll also ensure the branch selector populates from git branches. Next, I'll create a plan and start implementation.

Controllers and views for Git and Git::Grep are created, routes are registered, and tests pass. You now have:
- /git: shows a link to /git/grep
- /git/grep: branch selector (empty/local/remote), pattern field, files textarea, and grep results in <pre>.

Let me know if you want further customization or improvements!

