# "Rakefile" v1.0.0 | 2021/12/19 | by Tristano Ajmone | CC0 1.0 Universal

require 'asciidoctor'
require 'date'
require 'open3'

# ==============================================================================
# --------------------{  P R O J E C T   S E T T I N G S  }---------------------
# ==============================================================================

$repo_root = pwd
$cur_date = Date.today

ADOC_SRC = 'docs_src/index.asciidoc'
ADOC_DEPS = FileList['docs_src/index.asciidoc', 'docs_src/*.adoc']

PREVIEW_HTML = 'docs_src/preview.html'
GHPAGES_HTML = 'docs/index.html'

PREVIEW_ADOC_OPTS = <<~HEREDOC
  --failure-level WARN \
  --verbose \
  --timings \
  --safe-mode unsafe \
  -a IsHTML \
  -a imagesdir=../docs/ \
  -a revdate=#{$cur_date} \
  -o #{PREVIEW_HTML.pathmap("%f")}
HEREDOC

GHPAGES_ADOC_OPTS = <<~HEREDOC
  --failure-level WARN \
  --verbose \
  --timings \
  --safe-mode unsafe \
  -a IsHTML \
  -a imagesdir \
  -a revdate=#{$cur_date} \
  -o ../#{GHPAGES_HTML}
HEREDOC

COALESCER_RB = 'docs_src/asciidoc-coalescer.rb'
COALESCER_OUT = 'README.adoc'

COALESCER_OPTS = <<~HEREDOC
  -a IsADoc \
  -a env-github \
  #{ADOC_SRC.pathmap("%f")} \
  -o ../#{COALESCER_OUT}
HEREDOC

COALESCER_CMD = "ruby #{COALESCER_RB.pathmap("%f")} #{COALESCER_OPTS}"

# ==============================================================================
# ------------------------{  R U B Y   H E L P E R S  }-------------------------
# ==============================================================================

def SetFileTimeToZero(file)
  # ----------------------------------------------------------------------------
  # Set the last accessed and modified dates of 'file' to Epoch 00:00:00.
  # Sometimes we need to trick Rake into seeing a generated file as outdated,
  # e.g. because we're aborting the build when a tool raises warnings which
  # didn't prevent generating the target file, but we'd rather keep the file
  # for manual inspection -- since we're not sure whether it's malformed or not.
  # ----------------------------------------------------------------------------
  ts = Time.at 0
  File.utime(ts, ts, file)
end

def PrintTaskFailureMessage(our_msg, app_msg)
    err_head = "\n*** TASK FAILED! "
    STDERR.puts err_head << '*' * (73 - err_head.length) << "\n\n"
    if our_msg != ''
      STDERR.puts our_msg
      STDERR.puts '-' * 72
    end
    STDERR.puts app_msg
    STDERR.puts '*' * 72
end

def AsciidoctorConvert(source_file, adoc_opts = "")
  src_dir = source_file.pathmap("%d")
  src_file = source_file.pathmap("%f")
  adoc_opts = adoc_opts.chomp + " #{src_file}"
  cd "#{$repo_root}/#{src_dir}"
  begin
    stdout, stderr, status = Open3.capture3("asciidoctor #{adoc_opts}")
    puts stderr if status.success? # Even success is logged to STDERR!
    raise unless status.success?
  rescue
    rake_msg = our_msg = "Asciidoctor conversion failed: #{source_file}"
    out_file = src_file.ext('.html')
    if File.file?(out_file)
      our_msg = "Asciidoctor reported some problems during conversion.\n" \
        "The generated HTML file should not be considered safe to deploy."

      # Since we're invoking Asciidoctor with failure-level WARN, if the HTML
      # file was created we must set its modification time to 00:00:00 to trick
      # Rake into seeing it as an outdated target. (we're not 100% sure whether
      # it was re-created or it's the HTML from a previous run, but we're 100%
      # sure that it's outdated.)
      SetFileTimeToZero(out_file)
    end
    PrintTaskFailureMessage(our_msg, stderr)
    # Abort Rake execution with error description:
    raise rake_msg
  ensure
    cd $repo_root, verbose: false
  end
end

# ==============================================================================
# -------------------------------{  T A S K S  }--------------------------------
# ==============================================================================

task :default => :preview

desc "Clobber and run all tasks"
task :all => ['clobber', :preview, :build]

## HTML Preview
###############
desc "Build local HTML preview (default)"
task :preview => PREVIEW_HTML
file PREVIEW_HTML => ADOC_DEPS do |t|
  AsciidoctorConvert(ADOC_SRC, PREVIEW_ADOC_OPTS)
end

## Build
########
desc "Run tasks: 'www' + 'coalescer'"
task :build => [:www, :coalescer]

## WWW GHPages
##############
desc "Build GitHub Pages HTML"
task :www => GHPAGES_HTML
file GHPAGES_HTML => ADOC_DEPS do |t|
  AsciidoctorConvert(ADOC_SRC, GHPAGES_ADOC_OPTS)
end

## Coalescer
############
desc "Build coalesced README.adoc"
task :coalescer => COALESCER_OUT

file COALESCER_OUT => [*ADOC_DEPS, COALESCER_RB] do |t|
  cd "#{$repo_root}/#{ADOC_SRC.pathmap("%d")}"
  begin
    stdout, stderr, status = Open3.capture3(COALESCER_CMD)
    puts stderr if status.success? # Even success is logged to STDERR!
    raise unless status.success?
  rescue
    rake_msg = our_msg = "Asciidoctor coalescer failed to build #{COALESCER_OUT}"
    out_file = "../#{COALESCER_OUT}"
    if File.file?(out_file)
      our_msg = "Asciidoctor coalescer reported some problems.\n" \
        "The current \"#{COALESCER_OUT}\" file should not be " \
        "considered safe to deploy."

      # Since we're invoking Asciidoctor with failure-level WARN, if the HTML
      # file was created we must set its modification time to 00:00:00 to trick
      # Rake into seeing it as an outdated target. (we're not 100% sure whether
      # it was re-created or it's the HTML from a previous run, but we're 100%
      # sure that it's outdated.)
      SetFileTimeToZero(out_file)
    end
    PrintTaskFailureMessage(our_msg, stderr)
    # Abort Rake execution with error description:
    raise rake_msg
  ensure
    cd $repo_root, verbose: false
  end


end

## Clean & Clobber
##################
require 'rake/clean'
CLOBBER.include(COALESCER_OUT)
CLOBBER.include('**/*.html').exclude('**/docinfo.html')
