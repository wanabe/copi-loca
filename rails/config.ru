# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative "config/environment"
require_relative "lib/middleware/rollback_middleware"

use RollbackMiddleware
use Rack::Static,
  urls: ["/app"],
  root: "/",
  index: "index.html"

run Rails.application
Rails.application.load_server
