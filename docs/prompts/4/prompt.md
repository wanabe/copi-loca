---
name: add_more_specs
description: Add more specs and improve coerage
---
- Check docs/insufficient_coverage_report.json to identify areas with insufficient coverage.
- Write specs to cover the areas with insufficient coverage.
  - Basically, store one spec per target file in a single spec file.
    - The example spec file is spec/views/prompts/edit_spec.rb, which contains one spec for the target file app/views/prompts/edit.rb.
  - However, controllers are an exception:
    - Write request specs instead of controllers specs. Do not write controller specs.
    - For request specs, write one spec file per controller action.
      - The example request spec file is spec/requests/prompts/index_spec.rb, which is for app/controllers/prompts_controller.rb#index.
  - Some files listed in docs/missing_specs_checklist.json may already have specs, but their coverage might be insufficient.
    - If a spec exists, refer to the coverage information output in the coverage/ directory and add specs for uncovered areas.
