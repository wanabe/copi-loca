class Repository
  include ActiveModel::Model

  attr_accessor :path

  DEFAULT_PATH = "/app"

  def initialize(path: DEFAULT_PATH)
    @path = path
  end

  class << self
    def instance
      @instance ||= new(path: DEFAULT_PATH)
    end

    delegate(
      :log,
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
      to: :instance
    )
  end

  def git(cmd)
    `git -C #{@path} #{cmd} 2>&1`
  end

  def log(limit = 10)
    # Commit message must be last; '|' in message breaks split.
    log = git("log --pretty=format:'%H|%an|%s' -n#{limit}")
    log.lines.map do |line|
      hash, author, message = line.chomp.split("|", 3)
      { hash: hash, author: author, message: message }
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

  def unstage_file(file_path, commit: 'HEAD')
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

  def amend_no_edit
    git("commit --amend --no-edit")
  end

  def amend_with_message(message)
    git("commit --amend -m #{message.shellescape}")
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
end
