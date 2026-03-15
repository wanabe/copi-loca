The path format for the Prompt/Response models has been changed:
- Old: `.github/prompts/1.prompt.md`
- New: `docs/prompts/1/prompt.md`

In the specs:
- File path generation and Dir.glob patterns
- id extraction method
are still using the old format, so update them as follows:
`File.join(PATH_PREFIX, "#{id}#{PATH_SUFFIX}")` -> `File.join(PATH_PREFIX, "#{id}/#{PATH_SUFFIX}")`
`Dir.glob(File.join(PATH_PREFIX, "*#{PATH_SUFFIX}"))` -> `Dir.glob(File.join(PATH_PREFIX, "*/#{PATH_SUFFIX}"))`

Most spec updates for the path format are complete, but in the Prompt.all test, the following error appears:
`InstanceDouble(Prompt) (anonymous) received unexpected message :id`
This is because the double does not have the id method when using `sort_by(&:id)`. Add `allow(prompt).to receive(:id).and_return(1)` to the test double to resolve this.
Other specs are working correctly.

