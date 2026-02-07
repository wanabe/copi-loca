---
name: Template Agent
description: This is a template custom agent.
target: github-copilot
tools:
  - execute
  - read
  - edit
  - search
  - agent
  - web
  - todo
infer: true
mcp-servers:
  custom-mcp:
    type: 'local'
    command: 'some-command'
    args: ['--arg1', '--arg2']
    tools: ["*"]
    env:
      ENV_VAR_NAME: $
---

