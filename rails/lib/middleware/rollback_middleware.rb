class RollbackMiddleware
  ROLLBACK_PATH = "/r"
  RESTART_PATH = "/restart"

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    case request.path
    when ROLLBACK_PATH
      if request.post?
        begin
          output = `git -C /app reset --hard HEAD 2>&1`

          return [ 200, { "Content-Type" => "text/plain" }, [ "Rollback successful:\n#{output}" ] ]
        rescue => e
          return [ 500, { "Content-Type" => "text/plain" }, [ "Rollback failed: #{e.message}" ] ]
        end
      elsif request.get?
        html = <<~HTML
          <h1>Confirm Rollback</h1>
          <p>Are you sure you want to rollback the last commit? This action cannot be undone.</p>
          <form action="#{ROLLBACK_PATH}" method="post">
            <button type="submit">Yes, Rollback</button>
          </form>
        HTML
        return [ 200, { "Content-Type" => "text/html" }, [ html ] ]
      end
    when RESTART_PATH
      if request.post?
        Thread.new do
          sleep 2
          Kernel.exit(1)
        end
        return [ 200, { "Content-Type" => "text/plain" }, [ "Restarted." ] ]
      elsif request.get?
        html = <<~HTML
          <h1>Confirm Restart</h1>
          <p>Are you sure you want to restart the application? This action cannot be undone.</p>
          <form action="#{RESTART_PATH}" method="post">
            <button type="submit">Yes, Restart</button>
          </form>
        HTML
        return [ 200, { "Content-Type" => "text/html" }, [ html ] ]
      end
    end

    begin
      @app.call(env)
    rescue SyntaxError, LoadError => e
      error_message = "CRITICAL ERROR: #{e.class} - #{e.message}\n\n"
      html = "<h1>System Down</h1><pre>#{error_message}</pre>"
      html += "<form action='#{ROLLBACK_PATH}' method='post'><button>Force Rollback</button></form>"

      [ 500, { "Content-Type" => "text/html" }, [ html ] ]
    end
  end
end
