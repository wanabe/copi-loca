class ChangesController < ApplicationController
  def uncommitted
    raw = `git -C /app diff HEAD`
    @file_diffs = []
    current = nil
    raw.each_line do |line|
      if line.start_with?("diff --git ")
        @file_diffs << current if current
        # Extract path from 'diff --git a/path b/path'
        m = line.match(%r{diff --git a/(.+?) b/\1})
        path = m ? m[1] : nil
        current = [path, ""]
      elsif current
        # Skip index lines and +++/--- lines
        next if line.start_with?("index ")
        next if line.start_with?("+++ ")
        next if line.start_with?("--- ")
        next if line.start_with?("new file mode ")
        current[1] << line
      end
    end
    @file_diffs << current if current
    @file_diffs.reject! { |fd| fd[0].nil? }
    # Add untracked files
    untracked = `git -C /app ls-files --others --exclude-standard`.chomp.split("\n")
    untracked.each do |path|
      abs_path = Pathname.new("/app").join(path).expand_path.to_s
      if File.file?(abs_path)
        content = File.read(abs_path)
        lines = content.lines
        diff = "@@ -0,0 +1,#{lines.size} @@\n" + lines.map { |l| "+#{l}" }.join
        @file_diffs << [path, diff]
      else
        @file_diffs << [path, "Untracked file"]
      end
    end
    @file_diffs.sort_by! { |fd| fd[0] }
  end
  def revert
  end

  def execute_revert
    client = Client.instance.copilot_client
    client.create_session(model: "gpt-4.1") do |session|
      session.send("Please execute `git checkout . && git clean -fd`")
      client.wait { session.idle? }
    end

    redirect_to root_path, notice: "Code changes reverted."
  end
end
