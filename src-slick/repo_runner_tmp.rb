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
  
#### tree-sitter shunted dirs...

# lang_core_repos = ["tree-sitter-bash", "tree-sitter-python", "tree-sitter-html", "tree-sitter-rust", "tree-sitter-wasm", "tree-sitter-markdown", "tree-sitter-typescript", "tree-sitter-cpp", "tree-sitter-c", "tree-sitter-ruby", "tree-sitter-embedded-template", "tree-sitter-javascript", "tree-sitter-sexp", "tree-sitter-make", "tree-sitter-json", "tree-sitter-c-sharp"]
# lang_list = "tree-sitter-bash, tree-sitter-python, tree-sitter-html, tree-sitter-rust, tree-sitter-wasm, tree-sitter-markdown, tree-sitter-typescript, tree-sitter-cpp, tree-sitter-c, tree-sitter-ruby, tree-sitter-embedded-template, tree-sitter-javascript, tree-sitter-sexp, tree-sitter-make, tree-sitter-json, tree-sitter-c-sharp"
# lang_list_short = "bash, python, html, rust, wasm, markdown, typescript, cpp, c, ruby, embedded-template, javascript, sexp, make, json, c-sharp"


  def initialize
    cmd_list = {
#       "clone_lang_repo" => 
      "clone_lang" => 
        "Git clone tree-sitter-lang repo versions (curr only most recent)",
#       "clone_repo_by_tag" => "Git clone tree-sitter repo versions",
      "clone_runtime" => "Git clone tree-sitter repo versions",
#       "pull_lang" => "git clone tree-sitter-lang repo versions (curr only most recent)",
#       "pull_runtime" => "git clone tree-sitter repo versions",
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

# run
# ruby ../src/repo_runner.rb -i -l "bash, python, html, rust, wasm, markdown, typescript, cpp, c, ruby, embedded-template, javascript, sexp, make, json, c-sharp" -b make_lang

# ruby ../src/repo_runner.rb -i -l "html" -b make_lang
# -b bindings, -a symlinks hardcoded:
# ruby ../src/repo_runner.rb -i -l "html" make_lang

# ruby ../src/repo_runner.rb -a -i -l "html" make_lang <- symlinks

# now in proj dir:
# ruby src/repo_runner.rb -i -l "rust" make_lang
# ruby src/repo_runner.rb -a -i -l "rust" make_lang <- symlinks


#   def make_lang(repo, install=false)
  def make_lang(repo, g_opts)
    puts "=== #{repo}"
#     relpath_to_makefile = '../../src/Makefile-lang'
#     relpath_to_makefile = '../../src/Makefile-lang-shunt'
#     relpath_to_makefile = '../../src/Makefile-lang'
    relpath_to_makefile = '../../src/Makefile'
    FileUtils.cd(repo)
    call = 'make'
    call += ' --debug' # for verbose
    install = ' install' if g_opts.install
#     install = ' install-and-symlink' if g_opts.link # not impl in -shunt
#     install = ' install-c-binds' if g_opts.install
    install = ' install-and-symlink' if g_opts.alias # not impl in -shunt
#     install = ' installcbinds' if g_opts.bindings
    call += install if install
    call += " -f #{relpath_to_makefile}" unless g_opts.own_makefile && byo_makefile
    puts "  `#{call}`"
    puts `#{call}`
    FileUtils.cd('..')
  end

# assume the first \d+\.\d+\.\d+ is the vers tag we want
# sed is basic re, so \ parens and * not +
# VERS_TAG := $(shell echo $(VERS_TAG) | \
# 	sed -e \
# 		"s/[^[:digit:]]*\([[:digit:]]*\)\.\([[:digit:]]*\)\.\([[:digit:]]*\).*/\1.\2.\3/")
# endif
  
#   def clone_lang_repo(repo_url)
  def clone_lang_repo(repo_url)    
    repo_name, vers_tag = repo_name_and_vers_tag(repo_url)
    repo_dir = "#{repo_name}-#{vers_tag}"
    return repo_dir if Dir.exist?(repo_dir)
    FileUtils.mkdir_p(repo_dir)     
    FileUtils.cd(repo_dir)
    
    `git clone #{repo_url}.git`
    # collect last log entry for repo -- untested!!! FIXME!!!
    repo_name = repo_url.split('/').last
    FileUtils.cd(repo_name)
    log = `git log -1`
    FileUtils.cd('..')

    FileUtils.cd('..')
    nil # no news is good news
  end
  
  def repo_name_and_vers_tag(repo_url)
    repo_name = File.basename(repo_url)
    tag = `git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' #{repo_url} | tail -n1 | cut -d/ -f3`
    # assume the first \d+\.\d+\.\d+ is the vers tag we want
    vers_tag = tag.gsub(/^[^\d]*(\d+)\.(\d+)\.(\d+).*/,'\1.\2.\3')
    [repo_name, vers_tag]
  end
  
    
  def do_the_thing(g_opts, cmd, c_opts)
    puts "RepoRunner cmd: #{cmd.inspect}, g_opts: #{g_opts.inspect}"
    cmdline = case cmd
    when 'make_lang' 
      g_opts.lang_list.split(/,\s*/).each do |lang_repo| 
        repo = lang_repo.gsub(/^tree-sitter-/, '').gsub(/^/, 'tree-sitter-')
        make_lang(repo, g_opts)
      end
    when 'make_runtime' 
      g_opts.tag_list.split(/,\s*/).each do |vers_tag| 
        make_runtime("tree-sitter-v#{vers_tag}", g_opts)
      end
    when 'clone_lang'
      g_opts.lang_list.split(/,\s*/).each do |lang_repo|
        repo_dir = clone_lang_repo(lang_repo)
        puts "#{repo_dir} exists. Skipped." if repo_dir
      end
    end
    puts "done."
  end

# repo_tags = ["v0.20.0", "v0.20.6", "v0.20.7"]
# org_name = "tree-sitter"
# repo_name = "tree-sitter"
# repo_url = "http://github.com/#{org_name}/#{repo_name}"
# 
# # script_dir = FileUtils.pwd
# repo_tags.each do |tag|
#   repo_dir = "#{repo_name}-#{tag}"
#   if Dir.exist?(repo_dir)
#     puts "#=== {repo_dir} exists. skipping."
#     next
#   end
#   FileUtils.mkdir_p(repo_dir)
#   FileUtils.cd(repo_dir) 
#   puts "=== #{repo_url}"
#   `git clone -b #{tag} --depth 1 #{repo_url}.git`
#   FileUtils.cd('..')
# end


  
end

RepoRunner.go(__FILE__)
