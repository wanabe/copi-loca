# RSpec Writing Guidelines for Copi Loca

## Matcher Restrictions
- The use of `expect(...).to receive` is prohibited; it is deprecated and should not be used in any tests.

## File Correspondence Rule
- Each spec file must correspond one-to-one with its implementation file (e.g., model, controller, job, etc.).
- Do not create multiple spec files for a single model or implementation file. All tests for a given model must reside in a single spec file.

## General Principles
- Test each method individually; do not combine multiple methods in a single example (e.g., avoid 'describe "#a and #b"').
- Avoid direct manipulation of instance variables (e.g., do not use `instance_variable_set`).
- Do not use `instance_variable_get` for assertions; prefer public API or observable behavior.
- Use doubles and mocks for external dependencies (e.g., TCPSocket, Logger) to avoid real connections and side effects.

## Cache and Singleton Behavior
- When testing cache or singleton logic, verify both reuse (same object returned) and renewal (new object created after cache clear) using `object_id` or `equal` matcher.
- Always clear cache before tests that depend on cache state to avoid cross-test contamination.

## Block Handling
- When a method accepts a block, test both block and non-block usage.
- For block tests, ensure the block receives the expected object and is executed.

## Message Handling
- For methods that branch on message content (e.g., method name prefixes), cover all branches:
  - Prefix matches (e.g., 'session.' or 'tool.') and non-matches.
  - Use doubles for session/tool handlers and verify correct method calls.

## Redundancy and Clarity
- Remove redundant assertions; each test should have a clear, unique purpose.
- Use descriptive example names that clarify what is being tested and why.

## Example
```ruby
describe '.cache' do
  it 'returns cached client for given url' do
    client1 = Copilot::Client.cache(cli_url: cli_url)
    client2 = Copilot::Client.cache(cli_url: cli_url)
    expect(client2).to equal(client1)
  end

  it 'creates new client after cache clear' do
    client1 = Copilot::Client.cache(cli_url: cli_url)
    Copilot::Client.clear_cache
    client2 = Copilot::Client.cache(cli_url: cli_url)
    expect(client2).not_to equal(client1)
  end
end
```
