- Selected target file: app/views/files/show_directory.rb (highest priority, spec missing).
- Added spec: spec/views/files/show_directory_spec.rb, covering directory title, icons, and links.
- Updated docs/missing_specs_checklist.json to mark the spec as added for this file.

Task complete.

A spec for app/views/files/show_file.rb has been written and saved as spec/views/files/show_file_spec.rb. The checklist entry in docs/missing_specs_checklist.json is updated to indicate the spec has been added. Task complete.

I'll proceed as follows:
1. Identify the highest-priority file from docs/missing_specs_checklist.json that lacks a spec.
2. Write a spec for that file, following your conventions (request spec for controllers, standard spec otherwise).
3. Update docs/missing_specs_checklist.json to mark the spec as added.

First, I'll review docs/missing_specs_checklist.json and the example spec files to ensure correct format and conventions.

The highest-priority file without a spec is app/controllers/files_controller.rb, specifically the show action.

I'll write a request spec for this action in spec/requests/files/show_spec.rb, following the example format. Afterward, I'll update docs/missing_specs_checklist.json to mark the spec as added for this action.

The show action in FilesController handles file and directory display, error cases, and raw file sending. No spec exists yet for this action.

Next, I'll create spec/requests/files/show_spec.rb with request specs covering:
- Directory listing
- File display
- Raw file sending
- File not found
- Invalid path
- Unsupported file type

Afterward, I'll update docs/missing_specs_checklist.json to mark the spec as added.

Request spec for app/controllers/files_controller.rb#show is now written in spec/requests/files/show_spec.rb. The checklist in docs/missing_specs_checklist.json is updated to mark the spec as added. Task complete.

All files in docs/missing_specs_checklist.json already have specs added, as indicated by "spec_added": true for each entry. No further action is needed. If you have another checklist or want to add more specs, please provide the updated list or instructions.

All entries in docs/missing_specs_checklist.json already have specs added. No files remain without specs, so no further action is needed. If you want to check another checklist or add specs for new files, please update the checklist.

