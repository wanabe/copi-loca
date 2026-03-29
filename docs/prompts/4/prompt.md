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
  - However, directly calling private methods using send or similar techniques is prohibited. To increase coverage for private methods, write tests for the public methods that invoke those private methods.