FROM node:24-slim
RUN apt-get update && apt-get install -y git \
    && npm install -g @github/copilot
CMD ["copilot", "--server", "--port", "3100"]
