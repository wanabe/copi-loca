class Repository
  include ActiveModel::Model

  attr_accessor :path

  DEFAULT_PATH = "/app"

  def initialize(path: DEFAULT_PATH)
    @path = path
  end

  def git(cmd, env: nil)
    if env
      r, w = IO.pipe
      success = system(env, "git -C #{@path} #{cmd} 2>&1", out: w)
      w.close
      output = r.read
      r.close
    else
       output = `git -C #{@path} #{cmd} 2>&1`
    end

    unless Process.last_status.success?
      raise "Git failed: #{output}"
    end
    output
  end

  def log(limit = 10)
    # Commit message must be last; '|' in message breaks split.
    log = git("log --pretty=format:'%H|%an|%s' -n#{limit}")
    log.lines.map do |line|
      hash, author, message = line.chomp.split("|", 3)
      { hash: hash, author: author, message: message }
    end
  end

  def log_for_rebase(range: nil, base: nil, limit: nil)
    option = ""
    if range
      option << " #{range}"
    elsif base
      option << " #{base}..HEAD"
    end
    if limit
      option << " -n#{limit}"
    end
    git("log --reverse --format='%H %s'#{option}").lines.map do |line|
      hash, message = line.chomp.split(" ", 2)
      { hash: hash, message: message }
    end
  end

  def commit_info(commit)
    log = git("log -1 --pretty=format:'%an|%ai|%ci' #{commit}")
    author, author_date, commit_date = log.chomp.split("|", 3)
    { author: author, author_date: author_date, commit_date: commit_date }
  end

  def ls_files
    git("ls-files -c -o --exclude-standard").chomp.split("\n")
  end

  def untracked_diffs
    diffs = []
    untracked_files.each do |path|
      abs_path = Pathname.new(@path).join(path).expand_path.to_s
      if File.file?(abs_path)
        content = File.read(abs_path)
        lines = content.lines
        diff = "@@ -0,0 +1,#{lines.size} @@\n" + lines.map { |l| "+#{l}" }.join
        diffs << [ path, diff ]
      else
        diffs << [ path, "Untracked file" ]
      end
    end
    diffs
  end

  def tracked_diffs(commit)
    diff_raw = git("show -p --format='' #{commit}")
    diff_pairs(diff_raw)
  end

  def unstaged_diffs
    (diff_pairs(git("diff")) + untracked_diffs).sort_by { |fd| fd[0] }
  end

  def staged_diffs
    diff_pairs(git("diff --cached"))
  end

  def uncommitted_diffs
    (unstaged_diffs + staged_diffs + untracked_diffs).sort_by { |fd| fd[0] }
  end

  def untracked_files
    git("ls-files --others --exclude-standard").chomp.split("\n")
  end

  def commit_message(commit)
    git("log -1 --pretty=format:'%B' #{commit}")
  end

  def stage_file(file_path)
    git("add -- #{file_path}")
  end

  def unstage_file(file_path, commit: "HEAD")
    git("reset #{commit} -- #{file_path}")
  end

  def commit(message)
    git("commit -m #{message.shellescape}")
  end

  def amend_diffs
    diff_pairs(git("diff --cached HEAD~1"))
  end

  def head_commit_message
    git("log -1 --pretty=format:'%B' HEAD")
  end

  def amend_no_edit(reset_author: false)
    cmd = "commit --amend --no-edit"
    cmd += " --reset-author" if reset_author
    git(cmd)
  end

  def amend_with_message(message, reset_author: false)
    cmd = "commit --amend -m #{message.shellescape}"
    cmd += " --reset-author" if reset_author
    git(cmd)
  end

  def current_branch
    git("rev-parse --abbrev-ref HEAD").chomp
  end

  def rebase_directory
    %w[rebase-merge rebase-apply]
      .map { |dir| File.join(@path, ".git", dir) }
      .find { |dir| File.directory?(dir) }
  end

  # Returns a hash with detailed rebase status if rebasing, else nil
  # Example keys: :head, :onto, :done, :todo, :dir
  def rebase_status
    git_dir = rebase_directory
    return unless git_dir

    status = {
      dir: git_dir,
      head: content(git_dir, "head-name").chomp,
      onto: content(git_dir, "onto").chomp
    }
    commits = log_for_rebase(range: "#{status[:onto]}..#{status[:head]}")
    commit_map = commits.to_h { |c| [ c[:hash], c[:message] ] }

    {
      done: "done",
      todo: "git-rebase-todo"
    }.each do |key, fname|
      content = content(git_dir, fname)
      next unless content

      status[key] = content.lines.map do |line|
        if line !~ /^(\w+)(?:\s+([0-9a-f]{40})|$)/
          raise "Unexpected line in #{fname}: #{line}"
        end
        action = $1
        hash = $2
        message = commit_map[hash]
        { action: action, hash: hash, message: message }
      end.compact
    end
    status
  end

  # Performs an interactive rebase using a custom sequence file and GIT_SEQUENCE_EDITOR
  # steps: array of {hash:, action:} hashes in order
  # base: base commit hash (7 or 40 chars)
  def rebase_i(steps, base)
    sequence = ""
    squashing = false
    steps.each do |s|
      if s[:action] == "s" || s[:action] == "squash"
        squashing = true
      elsif squashing
        sequence << "break\n"
        squashing = false
      end
      sequence << "#{s[:action]} #{s[:hash]}\n"
    end
    Tempfile.create([ "rebase-sequence", ".txt" ]) do |file|
      file.write(sequence)
      file.flush
      env = {
        "GIT_SEQUENCE_EDITOR" => "cat #{file.path} >",
        "EDITOR" => ": "
      }
      git("rebase -i #{base}", env: env)
    end
  end

  def rebase_continue
    git("rebase --continue")
  end

  private
    def diff_pairs(diff_raw)
      diffs = []
      current = nil
      diff_raw.each_line do |line|
        if line.start_with?("diff --git ")
          diffs << current if current
          m = line.match(%r{diff --git a/(.+?) b/\1})
          path = m ? m[1] : nil
          current = [ path, "" ]
        elsif current
          next if line.start_with?("index ")
          next if line.start_with?("+++ ")
          next if line.start_with?("--- ")
          next if line.start_with?("new file mode ")
          current[1] << line
        end
      end
      diffs << current if current
      diffs.reject! { |fd| fd[0].nil? }
      diffs
    end

    def content(dir, fname)
      fpath = File.join(dir, fname)
      return unless File.exist?(fpath)
      File.read(fpath)
    end

  class << self
    def instance
      @instance ||= new(path: DEFAULT_PATH)
    end

    delegate(
      :log,
      :log_for_rebase,
      :diff,
      :status,
      :ls_files,
      :uncommitted_diffs,
      :untracked_files,
      :tracked_diffs,
      :unstaged_diffs,
      :staged_diffs,
      :commit_message,
      :stage_file,
      :unstage_file,
      :commit,
      :amend_diffs,
      :head_commit_message,
      :amend_no_edit,
      :amend_with_message,
      :commit_info,
      :current_branch,
      :rebase_status,
      :rebase_i,
      to: :instance
    )
  end
end
