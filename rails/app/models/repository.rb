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

    def log(limit = 10)
      instance.log(limit)
    end
    delegate :diff, :status, :ls_files, :uncommitted_diffs, :untracked_files, :tracked_diffs, :run_command, to: :instance
  end

  def self.git(cmd)
    `git -C #{DEFAULT_PATH} #{cmd}`
  end

  def git(cmd)
    `git -C #{@path} #{cmd}`
  end

  def log(limit = 10)
    log = git("log --pretty=format:'%H|%an|%s' -n#{limit}")
    log.lines.map do |line|
      hash, author, message = line.chomp.split('|', 3)
      { hash: hash, author: author, message: message }
    end
  end

  def diff
    git("diff")
  end


  def ls_files
    git("ls-files -c -o --exclude-standard").chomp.split("\n")
  end

  def tracked_diffs(commit = nil)
    diffs = []
    current = nil
    diff_raw = commit ? git("show -p --format='' #{commit}") : diff
    diff_raw.each_line do |line|
      if line.start_with?("diff --git ")
        diffs << current if current
        m = line.match(%r{diff --git a/(.+?) b/\1})
        path = m ? m[1] : nil
        current = [path, ""]
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

  def untracked_diffs
    diffs = []
    untracked_files.each do |path|
      abs_path = Pathname.new(@path).join(path).expand_path.to_s
      if File.file?(abs_path)
        content = File.read(abs_path)
        lines = content.lines
        diff = "@@ -0,0 +1,#{lines.size} @@\n" + lines.map { |l| "+#{l}" }.join
        diffs << [path, diff]
      else
        diffs << [path, "Untracked file"]
      end
    end
    diffs
  end

  def uncommitted_diffs
    (tracked_diffs + untracked_diffs).sort_by { |fd| fd[0] }
  end

  def untracked_files
    git("ls-files --others --exclude-standard").chomp.split("\n")
  end

  def run_command(cmd)
    output = ''
    status = nil
    Dir.chdir(@path) do
      reader, writer = IO.pipe
      pid = Process.spawn(cmd, out: writer, err: writer)
      writer.close
      output = reader.read
      _, process_status = Process.wait2(pid)
      status = process_status.exitstatus
      reader.close
    end
    [output, status]
  end
end
