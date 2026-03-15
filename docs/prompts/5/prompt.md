- List rb files that do not have corresponding spec files.
  - Target all Ruby scripts under app/ and lib/ directories.
  ^ Exclude other directories, such as config/.
- Output the list of enumerated files in JSON format under docs/.
  - This JSON file will be used as a checklist for adding specs in the future, so it should have an attribute to indicate whether specs have been added or not.