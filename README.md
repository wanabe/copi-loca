# Copi Loca

An application that provides a Web UI for accessing the GitHub Copilot CLI.

It is intended for use on a local network so you can access a home server from a smartphone.
It is not designed to be exposed to external networks.

# Warning

As noted above, this project is intended for local network use only.
It is not built with authentication or hardened security, so use it at your own risk.

# Getting Started

1. From the device you plan to use, ensure the server can be resolved as `(server-hostname).local`.
2. Create a personal access token (PAT) for Copilot.
  - ref: https://docs.github.com/en/copilot/how-tos/copilot-cli/install-copilot-cli#authenticating-with-a-personal-access-token
3. Run `bin/init`.
4. Start the server
   - with: `COPILOCA_GITHUB_TOKEN=(your PAT) COPILOCA_APP_PATH=(your app path) bin/docker compose up --build`
   - The `bin/docker` script injects the host name and user ID into the container.
   - See `bin/docker` for details.
5. Open `https://(server-hostname).local/sessions` in your browser.
6. Select the AI model you want and click the **Create Session** button.
7. Enter text and click **Create Message** to send a message; the generative AI will respond.

# Contributing

TODO

# License

MIT
