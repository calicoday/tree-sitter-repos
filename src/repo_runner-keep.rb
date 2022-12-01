# run: ruby repo_runner.rb opts cmd
# run make_runtime from proj:
#   ruby src/repo_runner.rb opts make_runtime
# run make_lang from tree-sitter-lang-daystamp wrap of lang repos:
#   ruby ../src/repo_runner.rb opts make_lang

require '/Users/cal/dev/gem_to_be.rb' # for Sunny
GemToBe.load(:sunny)
GemToBe.load(:optimist) # FILE needs to be loaded before sunny but loadpath doesn't matter

require "lab/sunny.rb"

require 'json'


require 'fileutils'
require 'awesome_print'

class RepoRunner < Sunny
  attr_reader :vers, :thaw
  attr_reader :lang_core
  
#### tree-sitter shunted dirs...

# lang_core_repos = ["tree-sitter-bash", "tree-sitter-python", "tree-sitter-html", "tree-sitter-rust", "tree-sitter-wasm", "tree-sitter-markdown", "tree-sitter-typescript", "tree-sitter-cpp", "tree-sitter-c", "tree-sitter-ruby", "tree-sitter-embedded-template", "tree-sitter-javascript", "tree-sitter-sexp", "tree-sitter-make", "tree-sitter-json", "tree-sitter-c-sharp"]
# lang_list = "tree-sitter-bash, tree-sitter-python, tree-sitter-html, tree-sitter-rust, tree-sitter-wasm, tree-sitter-markdown, tree-sitter-typescript, tree-sitter-cpp, tree-sitter-c, tree-sitter-ruby, tree-sitter-embedded-template, tree-sitter-javascript, tree-sitter-sexp, tree-sitter-make, tree-sitter-json, tree-sitter-c-sharp"
# lang_list_short = "bash, python, html, rust, wasm, markdown, typescript, cpp, c, ruby, embedded-template, javascript, sexp, make, json, c-sharp"

# ["tree-sitter-0.20.0", "tree-sitter-0.20.7", "tree-sitter-0.20.17", "tree-sitter-0.20.8"]

  def initialize
    @lang_core = {
      bash: "https://github.com/tree-sitter/tree-sitter-bash",
      c: "https://github.com/tree-sitter/tree-sitter-c",
      csharp: "https://github.com/tree-sitter/tree-sitter-c-sharp",
      cpp: "https://github.com/tree-sitter/tree-sitter-cpp",
      javascript: "https://github.com/tree-sitter/tree-sitter-javascript",
      json: "https://github.com/tree-sitter/tree-sitter-json",
      make: "https://github.com/alemuller/tree-sitter-make",
      markdown: "https://github.com/ikatyang/tree-sitter-markdown",
      python: "https://github.com/tree-sitter/tree-sitter-python",
      ruby: "https://github.com/tree-sitter/tree-sitter-ruby",
      rust: "https://github.com/tree-sitter/tree-sitter-rust",
      sexp: "https://github.com/AbstractMachinesLab/tree-sitter-sexp",
      typescript: "https://github.com/tree-sitter/tree-sitter-typescript",
      wasm: "https://github.com/wasm-lsp/tree-sitter-wasm",
      embedded_template: "https://github.com/tree-sitter/tree-sitter-embedded-template",
      html: "https://github.com/tree-sitter/tree-sitter-html",
    }

    cmd_list = {
      "clone_lang_core" =>
        "Git clone each of the core tree-sitter lang repos (curr only most recent version)",
      "clone_lang" => 
        "Git clone tree-sitter-lang repo versions (curr only most recent)",
#       "clone_repo_by_tag" => "Git clone tree-sitter repo versions",
      "clone_runtime" => "Git clone tree-sitter repo versions",
      "make_lang" => "Make tree-sitter-lang repo versions",
      "make_runtime" => "Make tree-sitter repo versions",
#       "install_lang" => "install tree-sitter-lang libs in conventional sys dir",
#       "install_runtime" => "install tree-sitter libs in conventional sys dir",
      }
    # vet cmd_list for matching method, if we're going to blindly redirect!!!
    cmd_opts = Proc.new {|cmd|
      }
    g_opts, cmd, c_opts = ready(cmd_list.keys, cmd_opts) do 
      version 'repo_runner.rb v0.0.1'
      banner("Runner of tree-sitter-repo scripts")
      banner "Usage:"
      banner "  repo_runner.rb [options] [<command> [suboptions]]\n \n"
      banner "Options:"
      # -v, -h get added auto but they land after the subcommands, so put them here
      opt(:version)
      opt(:help)
      
      opt(:debug, "Pass --debug option to make for verbose output")
      opt(:install, "Install lib in the conventional sys dir")
      opt(:alias, "Create a symlink to the installed lib with the simple, non-versioned name")
      opt(:bindings, "(for make_lang) Install external header for lang")

      # input:
      opt(:tag_list, "(for make_runtime) Tags of runtime versions to process, separated by /,\s*/", 
        :default => '', :type => String)
      opt(:lang_list, "(for make_lang) Names of lang repos to process, separated by /,\s*/ (accepts 'tree-sitter-lang' or just 'lang')", 
        :default => '', :type => String)
      # eg "0.20.0, 0.20.6, 0.20.7"

      opt(:file_for_make, "Use the specified Makefile (relative to repo dir)",
        :type => String)
      
      opt(:own_makefile, "Use repo's own Makefile, if any (applied to all)")
      # output: ### nec???
      opt(:shunt, "Shunt tag to use  (ie tree-sitter release) instead of  \
        repo's tag (applied to all)", :default => '0.20.6', :type => String)
      
      banner "\nCommands:"
      cmd_list.each { |cmd, desc| banner format("  %-10s %s", cmd, desc) }
    end
    
#     @vers = g_opts.shunt
#     @thaw = Pathname(g_opts.thaw ? g_opts.thaw : '') # if g_opts.thaw
#     if g_opts.thaw && thaw.exist?
#       puts "Thaw dir #{g_opts.thaw} already exists. Exiting."
#       exit 1
#     end

    # want these later!!!
    # runner testing
    cmdline = case cmd
    when 'noop'
      puts "Ok, exiting."
      exit 0
    when 'conf'
      return conf_nifty(g_opts, cmd, c_opts)
    end
    
    do_the_thing(g_opts, cmd, c_opts)
  end

  def byo_makefile
    Dir.children(Dir.pwd).map(&:upcase).include?('MAKEFILE')
  end

# run --tag_list not --lang_list!!! shd these be one name???
# ruby src/repo_runner.rb -i -t "0.20.0" make_runtime

# install_runtimes.rb
  def make_runtime(repo, g_opts)
    puts "RepoRunner make_runtime"
  #   relpath_to_makefile = '../../src/Makefile-runtime' ### langs from tree-sitter-lang/
    relpath_to_makefile = '../../src/Makefile-runtime'
    FileUtils.cd(repo)
    FileUtils.cd('tree-sitter')
    puts "in #{Dir.pwd}"
    call = 'make'
    call += ' --debug' if g_opts.debug
    install = ' install' if g_opts.install
    install = ' install-and-symlink' if g_opts.alias
    call += install if install
    call += " -f #{relpath_to_makefile}" unless g_opts.own_makefile && byo_makefile
    puts "  `#{call}`" # prompt
    puts `#{call}`
    FileUtils.cd('../..')
  end


# run in proj dir:
# ruby src/repo_runner.rb -i -l "rust" make_lang
# ruby src/repo_runner.rb -a -i -l "rust" make_lang <- symlinks
#   "bash, python, html, rust, wasm, markdown, typescript, cpp, c, ruby, embedded-template, javascript, sexp, make, json, c-sharp"

  def make_lang(g_opts, repo_name, vers_tag=nil)
#     vers_tag = most_recent(repo_name)
#     return repo_name unless vers_tag
#     repo_dir = "#{repo_name}-#{vers_tag}"

    repo_dir, vers_tag = most_recent(repo_name)
    return repo_name unless repo_dir
    
    puts "=== #{repo_dir}"
    relpath_to_makefile = '../../src/Makefile'
    FileUtils.cd(repo_dir)
    FileUtils.cd(repo_name)
    call = 'make'
    call += ' --debug' # for verbose
    install = ' install' if g_opts.install
    install = ' install-and-symlink' if g_opts.alias
    call += install if install
    call += " -f #{relpath_to_makefile}" unless g_opts.own_makefile && byo_makefile
    puts "  `#{call}`"
    puts `#{call}`
    FileUtils.cd('..')
    FileUtils.cd('..')
    nil # no news is good news
  end
  
  def most_recent(repo_name)
#     cand = Dir.children(Dir.pwd).select{|e| e =~ /^#{repo_name}\.\d+\.\d+\.\d+$/}
#     cand = Dir.children(Dir.pwd).select{|e| e =~ /^#{repo_name}-\d+\.\d+\.\d+$/}
    cand = list_shunt_dirs(repo_name)
    return nil if cand.empty?
#     best = cand.sort.last ### alpha sort!!!
#     [best, best.split(/#{repo_name}-/).last]
    # numeric sort
    best_vers = cand.map{|e| e.split(/^tree-sitter-/)}.map{|e| 
      e[1].split('.').map(&:to_i)}.sort.last.join('.')
    [shunt_dir(repo_name, best_vers), best_vers]
  end
  
  def git_clone(vers_tag=nil)
    vers_tag ?
      `git clone -b v#{vers_tag} --depth 1 #{repo_url}.git` :
      `git clone #{repo_url}.git`
  end
  
  def clone_lang(repo_url)    
    repo_name, vers_tag = repo_name_and_vers_tag(repo_url)
    repo_dir = shunt_dir(repo_name, vers_tag)
    return repo_dir if Dir.exist?(repo_dir)
    FileUtils.mkdir_p(repo_dir)     
    FileUtils.cd(repo_dir)
    
#     `git clone #{repo_url}.git`
    git_clone
    
#     # collect last log entry for repo -- untested!!! FIXME!!!
#     repo_name = repo_url.split('/').last
#     FileUtils.cd(repo_name)
#     log = `git log -1`

    FileUtils.cd('..')
    FileUtils.cd('..')
    nil # no news is good news
  end
  

  def clone_runtime(vers_tag)
    org_name = "tree-sitter"
    repo_name = "tree-sitter"
    repo_url = "http://github.com/#{org_name}/#{repo_name}"
    repo_dir = shunt_dir(repo_name, vers_tag)
    return repo_dir if Dir.exist?(repo_dir)
    
    FileUtils.mkdir_p(repo_dir)     
    FileUtils.cd(repo_dir)
    
#     `git clone -b v#{vers_tag} --depth 1 #{repo_url}.git`
    git_clone(vers_tag)

    FileUtils.cd('..')
    nil # no news is good news
  end

  # pull these out so hyphen/dot sep doesn't drift
  def list_shunt_dirs(repo_name)
    cand = Dir.children(Dir.pwd).select{|e| e =~ /^#{repo_name}-\d+\.\d+\.\d+$/}
  end
  def shunt_dir(repo_name, vers_tag)
    vers_tag = 'untagged' if vers_tag.empty?
    "#{repo_name}-#{vers_tag}"
#     "#{repo_name}.#{vers_tag}"
  end
  
  ### now with commit!!!
  def shunt_tag(repo_url)
    last_tag = `git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' \
      #{repo_url} | tail -n1`
    # for ref, using sed with basic REs not extended
#     commit = (last_tag.empty? ?
#       `git ls-remote #{repo_url} HEAD | sed -e "s/\(.......\).*/\1/"` :
#       `echo #{last_tag} | sed -e "s/\(.......\).*/\1/"`
    commit = (last_tag.empty? ? 
      `git ls-remote #{repo_url} HEAD` : last_tag).gsub(/^(.......).*/, '\1') :
    last_tag = 'untagged' if last_tag.empty?
    "#{last_tag}-#{commit}"    
  end
  
  def git_latest_tag(repo_url)
    `git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' #{repo_url} | tail -n1 | cut -d/ -f3` # => "0.20.3\n"
  end
  
  def repo_name_and_vers_tag(repo_url)
    repo_name = File.basename(repo_url)
#     tag = `git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' #{repo_url} | tail -n1 | cut -d/ -f3` # => "0.20.3\n"
    tag = git_latest_tag(repo_url)
    
    # assume the first \d+\.\d+\.\d+ is the vers tag we want
    vers_tag = tag.chomp.gsub(/^[^\d]*(\d+)\.(\d+)\.(\d+).*/,'\1.\2.\3')
    [repo_name, vers_tag]
  end
  
    
  def do_the_thing(g_opts, cmd, c_opts)
    puts `date`
    puts '+=+=+=+=+'
    puts "RepoRunner cmd: #{cmd.inspect}, g_opts: #{g_opts.inspect}"
    cmdline = case cmd
    when 'make_lang' 
      g_opts.lang_list.split(/,\s*/).each do |lang_repo| 
        repo = lang_repo.gsub(/^tree-sitter-/, '').gsub(/^/, 'tree-sitter-')
        repo_name = make_lang(g_opts, repo)
        puts "Couldn't find vers_tag for #{repo_name}" if repo_name
      end
    when 'make_runtime' 
      g_opts.tag_list.split(/,\s*/).each do |vers_tag| 
        make_runtime("tree-sitter-v#{vers_tag}", g_opts)
      end
    when 'clone_lang'
      g_opts.lang_list.split(/,\s*/).each do |lang_repo|
        repo_dir = clone_lang(lang_repo)
        puts "#{repo_dir} exists. Skipped." if repo_dir
      end
    when 'clone_runtime'
      g_opts.tag_list.split(/,\s*/).each do |vers_tag| 
        repo_dir = clone_runtime(vers_tag)
        puts "#{repo_dir} exists. Skipped." if repo_dir
      end
    when 'clone_lang_core'
      lang_core.values.each do |lang_repo|
        repo_dir = clone_lang(lang_repo)
        puts "#{repo_dir} exists. Skipped." if repo_dir
      end
    end
    puts "done."
  end

  
end

RepoRunner.go(__FILE__)
