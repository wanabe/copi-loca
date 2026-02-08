FROM rubylang/ruby:4.0-noble

# Install system dependencies for typical Rails dev (bundler, node, sqlite)
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  libsqlite3-dev \
  sqlite3 \
  nodejs \
  curl \
  gnupg \
  libyaml-dev \
  git \
  libssl-dev \
  && rm -rf /var/lib/apt/lists/*
