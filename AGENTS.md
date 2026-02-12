# Overview

## Project Overview

Copi Loca is a Rails-based web UI for interacting with Copilot AI agents. Users can create and manage multiple AI sessions, exchange messages, and view all RPC logs with the backend Copilot service. The application persists sessions, messages, and logs in a SQLite database and provides a clear, message-driven architecture for extensibility and debugging.

### Core Features
- Session management with selectable AI models
- Message exchange within sessions (user prompt and AI response)
- Full RPC logging for all backend communication
- Persistent storage of sessions, messages, and logs

### Architecture
- Rails 8.1.2, SQLite, Falcon server, Hotwire frontend
- Docker Compose orchestrates Rails, Copilot backend, and Caddy reverse proxy
- Caddy serves as the public entrypoint and reverse proxy for Rails
- Communicates with Copilot service via TCP (localhost:3100)
- Message-driven, event-based design

### Directory Structure
- rails/
  - app/
    - controllers: Session, Message, RPC log, Home, Models, AuthSessions controllers
    - models: Session, Message, RpcLog, Client
    - views: ERB templates for sessions, messages, logs, authentication
    - jobs: background job classes
    - helpers: view helpers
    - assets: static assets
    - javascript: JS files
  - config/
    - application.rb: Rails config
    - routes.rb: RESTful routing
    - initializers/: custom initializers
    - environments/: env configs
    - database.yml: DB config
  - db/
    - migrate/: schema migrations
    - schema.rb: current schema
    - seeds.rb: seed data
  - lib/
    - copilot/: Copilot client logic
  - test/: tests for models, controllers, jobs
- caddy/
  - Caddyfile: reverse proxy config
  - Dockerfile: Caddy container
- copilot/
  - Dockerfile: Copilot backend container
- bin/: scripts
- compose.yml: Docker Compose orchestration

### Database Schema
- Sessions: id (UUID), model, timestamps
- Messages: session_id, rpc_log_id (AI only), direction, content, timestamps
- RpcLogs: session_id, rpc_id, direction, data (JSON), timestamps

### Data Flow
1. User sends a message in a session; Message and outgoing RpcLog are created
2. Copilot event is received; incoming Message and RpcLog are created
3. Session management (create, resume, destroy) handled via Client

### Key Workflows for AI Agents
- Entry: config/routes.rb, controllers, models, and views
- Add features: update schema, models, controllers, and views
- Debug: check RpcLog and session/message associations

### Maintenance Notes
- Session IDs are UUID strings
- All RPC communication is logged for debugging
- Message.rpc_log_id is set only for AI responses
- Consider log cleanup for storage
- Copilot service runs in a separate container (see compose.yml)
- **CAUTION**: If you add authentication via before_action in ApplicationController, be sure to skip authentication for Turbo Stream requests (e.g., `skip_before_action :authenticate, if: -> { request.format.turbo_stream? }`). Otherwise, real-time updates will break because Turbo Streams requests will be redirected to the login page.


# Commands

# Testing

# Project Structure

# Code Style

## Git commit messages, Documents and comments

Git commit messages, Comments and documentation in languages other than English are prohibited.
If comments or documentation appear in a language other than English, translate them into English.

# Git Workflow

- Do not commit changes unless the user explicitly instructs you to commit. Never commit automatically or without user permission.

# Boundaries

# Chat Style

When interacting with users, follow these points:
- Respond in the language the user is using.
  - If a question is asked in a language other than English, reply in that language.
  - However, keep technical terms and code snippets in English.
