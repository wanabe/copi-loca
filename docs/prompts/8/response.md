To enable stage/unstage actions from the Heads "new" screen, we need to:

1. Add clickable icons next to each file in both the "Unstaged" and "Staged" sections.
2. When an icon is clicked, trigger a POST request to either the `stage` or `unstage` action with the file path.
3. Update the UI to reflect the new state after the action.

I will update the view to add these interactive icons and the necessary JavaScript for the AJAX calls.

The CSRF meta tag is rendered via `render csrf_meta_tags` in the layout, so the JavaScript will work as expected.

**Summary of changes:**
- Added stage/unstage buttons to each file in the "Unstaged" and "Staged" sections.
- Implemented JavaScript to send AJAX POST requests to the correct endpoints and reload on success.

Next, I will run the Rails server or tests to verify the UI and actions work as intended.

Stage/unstage actions are now available from the Heads "new" screen. Clicking the icon next to a file will stage or unstage it via AJAX, and the UI will update accordingly. All tests and specs pass, confirming the integration works as intended. Task complete!

