# Database Schema Guidelines for Copi Loca

## Table Definitions
- sessions: id (string, Copilot session ID), model, skill_directory_pattern, token_limit, current_tokens, timestamps
- messages: session_id, rpc_message_id (AI only), direction, content, timestamps
- rpc_messages: session_id, rpc_id, direction, method, params, result, error, message_type, timestamps
- operations: command, directory, execution_timing, timestamps
- custom_agents: name, display_name, description, prompt, timestamps
- session_custom_agents: session_id, custom_agent_id, timestamps
- tools: name, description, script, timestamps
- tool_parameters: tool_id, name, description, timestamps
- session_tools: session_id, tool_id, timestamps
- events: session_id, rpc_message_id, event_id, event_type, data, parent_event_id, ephemeral, timestamp, timestamps

## Migration/Schema Operations
- Update this file when adding or changing tables
- Clearly describe column names, types, and purposes
- Link from root AGENTS.md
