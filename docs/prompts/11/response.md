The POST actions Git::HeadsController#stage_line and #unstage_line have been added, accepting path, hunk, lineno, and for parameters, logging them, and redirecting as specified. The stimulus controller now calls these actions, with the for/action logic passed from HeadForm -> Patch -> JS. Redirects are handled on the client. All changes are complete.

