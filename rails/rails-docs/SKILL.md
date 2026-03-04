# Phlex Migration Skill: Converting ERB Views to Phlex (Views::* classes)

This document describes the exact step-by-step migration process used to convert Rails ERB view templates into Phlex-based view classes under the `Views::` namespace. The instructions are written for an automated agent (AI) to follow reliably and safely.

Goals
- Convert page-level ERB templates into Phlex view classes placed under `rails/app/views/.../*.rb` with `Views::...` namespace.
- Keep functional parity with the original ERB rendering.
- Make migration incremental and reversible: keep backups and avoid destructive changes without user approval.

Principles
- Be explicit: prefer named keyword arguments to mass-assignment via `**kwargs` when creating Phlex classes.
- Preserve original ERB content during migration (save backups) until the user confirms deletion.
- Do not remove files or commit changes without user approval.
- Keep controller changes explicit: render Phlex classes with `render Views::... .new(...)` rather than relying on implicit ERB rendering.

Procedure (per view)
1. Identify candidate ERB
   - A candidate is a top-level ERB file under `rails/app/views` that represents a page (not a partial or layout).
   - Exclude files under `rails/app/views/layouts` and files whose basename starts with `_`.

2. Inspect the ERB and determine necessary inputs
   - Read the ERB and find all local variables and controller instance variables referenced (e.g., `@models`, `@commit_info`, `@file_paths`, `params` usage.)
   - Decide which controller-provided values the Phlex class must accept as explicit keyword arguments.

3. Create Phlex view class under `rails/app/views/.../<name>.rb`
   - Namespace class under `Views::<Path>::<CamelName>`, e.g., `rails/app/views/changes/show.rb` -> `class Views::Changes::Show < Components::Base`.
   - Define an explicit initializer with the selected keyword arguments:
     def initialize(id:, file_paths:, commit_info:, commit_message:, selected_file_path: nil, file_diff: nil)
       @id = id
       @file_paths = file_paths
       ...
     end
   - Implement `def view_template` that reproduces the ERB output using Phlex primitives. Use `ERB::Util.html_escape` for content that previously used `h(...)`.
   - When the original ERB used helpers (link_to, paginate, etc.), call them through `view_context` (e.g., `view_context.link_to(...)`) or use the Rails helper wrappers available in `Components::Base`.
   - For complex partials still implemented as Components, call `raw render(Components::...::Component.new(...))` from `view_template`.

4. Leave the ERB untouched during initial migration
   - Do not modify the ERB file during the initial migration step. Instead, update the controller action to render the Phlex view directly; the ERB will become unused and can be removed later under explicit user approval.
   - Creating backups at this step is optional. If you prefer to keep originals for audit or rollback, move them to `rails/app/views/_orig/...` or create a `.bak` file; otherwise, defer deletion to the cleanup phase after verification.

5. Update controller to explicitly render the Phlex view (recommended)
   - In the controller action (e.g., `def show`), after setting instance variables, call
     render Views::Changes::Show.new(id: @id, file_paths: @file_paths, ...)
   - Pass `params` only if necessary and prefer converting usages to pass the specific values instead (e.g., `selected_file_path: params[:file_path]`).

6. Test & iterate
   - Restart server and test the page manually.
   - If errors referencing `params` occur inside Phlex, ensure the controller passes necessary values as keyword args and use `@params` consistently in the Phlex initializer.
   - If helpers raise `private method` errors (e.g., `h`), replace `view_context.h(...)` with `ERB::Util.html_escape(...)` in the Phlex template or call helpers via `view_context`.

7. Cleanup
   - After successful verification, remove the original ERB files if the user approves. Backups are optional; if originals were retained under `_orig/` or as `.bak`, delete them only with explicit user consent.
   - Optionally, convert remaining multi-line ERB files using a safe wrapper pattern: create a Phlex class that calls `view_context.render(file: Rails.root.join('app','views','_orig','...').to_s)` and move original ERB to `_orig/`.

Notes and Gotchas
- Autoloading: placing `.rb` files under `rails/app/views` with `Views::` namespace relies on Rails autoload paths; ensure the path is included in autoload/eager_load. If not, consider placing Phlex view classes under `rails/app/components/views` or adding an initializer.
- Escaping: prefer `ERB::Util.html_escape` for static content. Use `raw` only for safe HTML coming from pre-escaped sources or components.
- Avoid mass-assignment of kwargs into instance variables in production code; list expected arguments explicitly for clarity and security.
- When in doubt, prefer making a conservative, reversible change and ask the user.

Example: Changes#show
- Created `rails/app/views/changes/show.rb` (Views::Changes::Show) with explicit initializer and `view_template` reproducing the ERB output.
- Controller `ChangesController#show` was updated to `render Views::Changes::Show.new(...)` with explicit args.
- The original ERB `rails/app/views/changes/show.html.erb` was removed only after successful verification.

End of skill
