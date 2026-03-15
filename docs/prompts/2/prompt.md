---
name: phlex_migration_checklist
description: Create checklist for Phlex view migration
---
I want to rewrite the views using Phlex. 
Please prepare a checklist that allows tracking the migration steps and current progress.
Please output the checklist in JSON format under the docs/ directory.
When creating the list, please note the following:
- Only HTML templates are subject to migration.
  - Text and JSON files are not subject to Phlex migration.
- Please set the order carefully.
  - Start with the simplest partials that do not include other partials.
  - Next, if any, migrate partials that render other partials.
  - Then migrate the views.
  - Layouts should be migrated last.