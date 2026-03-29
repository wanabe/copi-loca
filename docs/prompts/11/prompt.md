Please add POST actions called Git::HeadsController#stage_line and #unstage_line.
Accept the following parameters: path, hunk, lineno, and for.
The for parameter will be either the string "new" or "edit". If any other value is provided, treat it as "new".
For now, just output path, hunk, and lineno to Rails.logger. We will implement further logic later.
After logging, if for is new, redirect to the new action page; if edit, redirect to the edit action page.

Currently, app/javascript/controllers/patch_highlight_controller.js only displays which line's prefix was clicked.
Change this so that it calls the above Git::HeadsController#stage_line or #unstage_line actions.
Which action to call and what to pass as the for parameter should be determined in Components::Git::HeadForm, passed to Components::Git::Patch, and then passed to the stimulus controller.
Also, if a redirect occurs as a result of the action call, make sure the page is redirected appropriately.