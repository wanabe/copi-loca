The `Git::HeadsController#create` action has been implemented. It performs a `git commit` using `Git.call!` with the commit message from the form, then redirects to the `new` page. The `new` view now includes a textarea and button for entering and submitting the commit message. All tests pass, confirming the integration works as expected.

