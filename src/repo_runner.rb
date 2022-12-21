# run: ruby repo_runner.rb opts cmd
# run make_runtime from proj:
#   ruby src/repo_runner.rb opts make_runtime
# run make_lang from tree-sitter-lang-daystamp wrap of lang repos:
#   ruby ../src/repo_runner.rb opts make_lang

require '/Users/cal/dev/gem_to_be.rb' # for Sunny
GemToBe.load(:sunny)
GemToBe.load(:optimist) # FILE needs to be loaded before sunny but loadpath doesn't matter

require "lab/sunny.rb"

# for list_lang_repos to scrape tree-sitter.github.io source file index.md for langs
require 'open-uri'

# for lang_repos.json and repos.json
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
      c_sharp: "https://github.com/tree-sitter/tree-sitter-c-sharp",
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
      "try" => "Try experimental Makefile for dev",
      "noop" => "No-op for dev",
      "clone" => "Clone runtime/lang repos",
      "make" => "Make runtime/lang repos",
      "clean_libs" => "Rm all built libs in repos",
      "clone_lang_core" =>
        "Git clone each of the core tree-sitter lang repos (curr only most recent version)",
      "clone_lang" => 
        "Git clone tree-sitter-lang repo versions (curr only most recent)",
#       "clone_repo_by_tag" => "Git clone tree-sitter repo versions",
      "clone_runtime" => "Git clone tree-sitter repo versions",
      "make_lang_core" => "Make each of the core tree-sitter lang repos (curr only most recent version)",
      "make_lang" => "Make tree-sitter-lang repo versions",
      "make_runtime" => "Make tree-sitter repo versions",
#       "install_lang" => "install tree-sitter-lang libs in conventional sys dir",
#       "install_runtime" => "install tree-sitter libs in conventional sys dir",
      "list_lang_repos" => "Show the language repos listed in tree-sitter.github.io Introduction",
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
      opt(:noop, "Pass --noop option to make for dry run")
      opt(:install, "Install lib in the conventional sys dir")
      opt(:alias, "Create a symlink to the installed lib with the simple, non-versioned name")
#       opt(:bindings, "(for make_lang) Install external header for lang")
      
      opt(:workdir, "Working directory for cloned/built repos", 
        :default => 'repos/', :type => String)

      # input:
      opt(:tag_list, "(clone or make) Tags of runtime versions to process, separated by /,\s*/", 
        :default => '', :type => String)
      opt(:lang_list, "(clone or make) Short names of lang repos to process, separated by /,\s*/ (ie just 'lang' for 'tree-sitter-lang'). For clone, requires --json lang info file with a matching entry for each", 
        :default => '', :type => String)
      # eg "0.20.0, 0.20.6, 0.20.7"
      opt(:repo_dirs, "(make) Versioned repo dirs, separated by /,\s*/", 
        :default => '', :type => String)
      
      opt(:json, "JSON file with a list of repos and versions to clone or make",
        :default => '', :type => String)

#       opt(:file_for_make, "Use the specified Makefile (relative to repo dir)",
#         :type => String)
#       
#       opt(:own_makefile, "Use repo's own Makefile, if any (applied to all)")
#       # output: ### nec???
#       opt(:shunt, "Shunt tag to use  (ie tree-sitter release) instead of  \
#         repo's tag (applied to all)", :default => '0.20.6', :type => String)
      
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
#     when 'noop'
#       puts "Ok, exiting."
#       exit 0
    when 'conf'
      return conf_nifty(g_opts, cmd, c_opts)
    end
    
    do_the_thing(g_opts, cmd, c_opts)
  end


  # make given specific repo_dir
  def make_lib(g_opts, repo_dir, repo_name=nil)
    # if no repo_name, use repo_dir up to the vers
    puts "repo_dir: #{repo_dir}, repo_name: #{repo_name}"
    repo_name = repo_dir.gsub(/\..*/, '') unless repo_name
    puts "  repo_name: #{repo_name}"
    relpath_to_makefile = '../../../makings/Makefile' # one more for workdir!!!
    
    puts
    puts "=== #{repo_dir}"
    FileUtils.cd(repo_dir)
    FileUtils.cd(repo_name)
    call = 'make'
    call += ' -n' if g_opts.noop
    call += ' --debug' if g_opts.debug
    install = ' install' if g_opts.install
    install = ' install-and-symlink' if g_opts.alias
    call += install if install
    call += " -f #{relpath_to_makefile}"
    puts "  `#{call}`"
    puts `#{call}`
    FileUtils.cd('..')
    FileUtils.cd('..')
    nil # no news is good news    
  end
  
#   def make_repo(g_opts, repo_name, vers_tag)
#   def make_repo(g_opts, repo_dir, repo_name)
#     make_lib(g_opts, repo_dir, repo_name)
# 
# #   make_runtime(g_opts, "tree-sitter.#{vers_tag}")
# #   def make_runtime(g_opts, repo_dir)
#     repo_dir = "#{repo_name}.#{vers_tag}"
#     
# #   def make_lang(g_opts, repo_name, vers_tag=nil)
#     repo_dir, vers_tag = most_recent(repo_name)
#     return repo_name unless repo_dir
# 
#   end


# run --tag_list not --lang_list!!! shd these be one name???
# ruby src/repo_runner.rb -i -t "0.20.0" make_runtime

# install_runtimes.rb
  def make_runtime(g_opts, repo_dir)
    puts "RepoRunner make_runtime #{repo_dir}"
    make_lib(g_opts, repo_dir, 'tree-sitter')
  end

# run in proj dir:
# ruby src/repo_runner.rb -i -l "rust" make_lang
# ruby src/repo_runner.rb -a -i -l "rust" make_lang <- symlinks
#   "bash, python, html, rust, wasm, markdown, typescript, cpp, c, ruby, embedded-template, javascript, sexp, make, json, c-sharp"

  def make_lang(g_opts, repo_name, vers_tag=nil)
    repo_dir, vers_tag = most_recent(repo_name)
    return repo_name unless repo_dir

    make_lib(g_opts, repo_dir)
  end
  
  def most_recent(repo_name)
    cand = list_shunt_dirs(repo_name)
    puts "^^^ most_recent repo_name: #{repo_name}"
    return nil if cand.empty?
#     best = cand.sort.last ### alpha sort!!!
    # numeric sort
    best_vers = 'untagged' if cand.length == 1 && cand[0] == "#{repo_name}.untagged"
    best_vers = cand.map{|e| e.split(/^#{repo_name}\./)}.map{|e| 
      e[1].split('.').map(&:to_i)}.sort.last.join('.') unless best_vers
    [shunt_dir(repo_name, best_vers), best_vers]
  end
  
#   def git_clone(repo_url, vers_tag)
  def git_clone(repo_url, vers_tag=nil)
    vers_tag ?
      `git clone -b v#{vers_tag} --depth 1 #{repo_url}.git` :
      `git clone #{repo_url}.git`
  end
  
  def  clone_repo(repo_url, repo_name, vers_tag)
    puts "=== clone_repo(#{repo_url.inspect}, #{repo_name.inspect}, #{vers_tag.inspect})"
    repo_dir = shunt_dir(repo_name, vers_tag)
    return repo_dir if Dir.exist?(repo_dir)
    
    repos_info = {}
    repos_info = JSON.parse(File.read('repos.json'))if File.exist?('repos.json')
    
    # get the commit from lang_deets, not relevant but harmless for tagged runtime 
    lang_name, deets = lang_deets(repo_url, nil, nil) ### refac!!!
    
    FileUtils.mkdir_p(repo_dir)     
    FileUtils.cd(repo_dir)
    
    git_clone(repo_url, vers_tag)
    
    # now map the dirs, add it to repos_info and rewrite repos.json
    parser_paths = Dir['**/*'].select{|e| !File.directory?(e) && e =~ /\bparser.c\b/}    
    repos_info[repo_dir] = {layout: parser_paths} # other info???
    # it will womp :layout if snap/untagged but we'll note the commit for ref
    repos_info[repo_dir][:commit] = deets[:commit] if deets[:vers] == 'untagged'
    repos_info[repo_dir][:date_cloned] = `date`

    FileUtils.cd('..')
    
    # write repos.json
    File.write('repos.json', JSON.pretty_generate(repos_info))
    
    nil # no news is good news
  end
  
  # ruby src/repo_runner.rb -l "wasm" clone_lang ### nope, no shorthand!!! FIXME!!!
  # ruby src/repo_runner.rb -l "https://github.com/wasm-lsp/tree-sitter-wasm" clone_lang
  def clone_lang(repo_url)    
    repo_name, vers_tag = repo_name_and_vers_tag(repo_url)
    clone_repo(repo_url, repo_name, vers_tag)
  end
  
  # ruby src/repo_runner.rb -t "0.20.0, 0.20.6, 0.20.7" clone_runtime
  def clone_runtime(vers_tag)
    org_name = "tree-sitter"
    repo_name = "tree-sitter"
    repo_url = "http://github.com/#{org_name}/#{repo_name}"
    clone_repo(repo_url, repo_name, vers_tag)
  end

  # These two are the only methods that know the shunt name format for contruct/match
  def list_shunt_dirs(repo_name)
#     cand = Dir.children(Dir.pwd).select{|e| 
#       e =~ /^#{repo_name}(\.\d+\.\d+\.\d+|\.untagged)$/}
    cand = Dir.children(Dir.pwd).select{|e| e =~ /^#{repo_name}\.\d+\.\d+\.\d+$/ ||
      e =~ /^#{repo_name}\.untagged/}
  end
  def shunt_dir(repo_name, vers_tag)
    vers_tag = 'untagged' unless vers_tag && vers_tag != 'untagged'
    "#{repo_name}.#{vers_tag}"
  end
  
  def git_last_commit_and_tag_or_head(repo_url)
    commit, last_tag = `git -c 'versionsort.suffix=-' ls-remote --tags \
      --sort='v:refname'  #{repo_url} | tail -n1`.chomp.split("\t")
    # if we didn't get a commit, the repo has never been tagged and we'll use HEAD
    commit, last_tag = `git ls-remote #{repo_url} HEAD`.chomp.split("\t") unless commit
    [commit, last_tag]
  end
  
  # works for any but untagged haven't got anything else
  def git_untagged_head(repo_url)
    `git ls-remote #{repo_url} HEAD`.chomp
  end
  
  ### commit unused so far, poss for active?() ???
  def git_last_tag_and_commit(repo_url) # hash length option???
    last_tag = `git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' \
      #{repo_url} | tail -n1`.chomp
    # for ref, using sed with basic REs not extended
#     commit = (last_tag.empty? ?
#       `git ls-remote #{repo_url} HEAD | sed -e "s/\(.......\).*/\1/"` :
#       `echo #{last_tag} | sed -e "s/\(.......\).*/\1/"`
    commit = (last_tag.empty? ? 
      git_untagged_head(repo_url) : last_tag).gsub(/^(.......).*/, '\1')
    last_tag = nil if last_tag.empty?
    [last_tag, commit]
  end
  
  # only used by clone_lang
  def repo_name_and_vers_tag(repo_url)
    repo_name = File.basename(repo_url)
#     commit, last_tag = git_last_commit_and_tag_or_head(url)
#     vers_tag = (last_tag == 'HEAD' ?
#       'untagged' :
#       last_tag.gsub(/.*(\d+\.\d+\.\d+).*$/, '\1'))
#     [repo_name, vers_tag]

    tag, _ = git_last_tag_and_commit(repo_url)
    
    # assume the first \d+\.\d+\.\d+ is the vers tag we want
    vers_tag = (tag ? 
      tag.split(/\t+/).last.gsub(/^[^\d]*(\d+)\.(\d+)\.(\d+).*/,'\1.\2.\3') : 
      nil)
    [repo_name, vers_tag]
  end
  
  
  def lang_entry(s)
    s.gsub(/^[^\[]*\[([^\]]*)\].*(http[^\)]*)\).*/, '\2: \1')
  end
  def gather_langs(chunk)
    chunk.split("\n").
      map{|e| lang_entry(e)}.
      map{|e| e.split(': ')}.
      reject{|e| e.length != 2}.to_h
  end
  def lang_deets(url, descr, status)
    # Erlang url has trailing '/' in tree-sitter.github.io src index.md
    url = url.gsub(/\/$/, '')
    commit, last_tag = git_last_commit_and_tag_or_head(url)
    vers = (last_tag == 'HEAD' ?
      'untagged' :
      last_tag.gsub(/.*(\d+\.\d+\.\d+).*$/, '\1'))
    # new form: k is url, v is info (no short name)
#     [url,  
#       {descr: descr, vers: vers, last_tag: last_tag, commit: commit, status: status}]
    # orig form was better:
    lang = url.gsub(/.*tree-sitter-(.*)/, '\1')
    [lang.gsub(/-/, '_').to_sym,  
      {descr: descr, url: url, vers: vers, last_tag: last_tag, commit: commit, 
      status: status}]
  end
  def list_lang_repos()
    if File.exist?('src/lang_repos_keep.json')
      puts "src/lang_repos_keep.json exists. Exiting."
      exit 1
    end
    FileUtils.mv('src/lang_repos.json', 
      'src/lang_repos_keep.json') if File.exist?('src/lang_repos.json')
  
    s = open('https://raw.githubusercontent.com/tree-sitter/' + 
      'tree-sitter/master/docs/index.md').read
    seps = ['Parsers for these languages are fairly complete:',
      'Parsers for these languages are in development:',
      'Talks on Tree-sitter']
    chunks = s.split(/(#{seps.join('|')})/)
    
    info = {fairly_complete: chunks[2], in_development: chunks[4]}.map do |status, chunk|
      lang_list = gather_langs(chunk)
#       ap lang_list
      puts "#{lang_list.length} #{status} parsers:"
      lang_list.map.with_index do |e, i|
        k, v = e
        puts "  #{i} checking #{k}"
        lang_deets(k, v, status)
      end
    end.flatten(1).to_h

    File.write('src/lang_repos.json', JSON.pretty_generate(info))
  end
  
  
  def tag_targets(tag_list)
    return [] if tag_list.empty?
    tag_list.split(/,\s*/).map do |e| 
      ['https://github.com/tree-sitter/tree-sitter', 'tree-sitter', e]
    end
  end
  # check against --json for what to clone
  def clone_targets(g_opts)
    if g_opts.json.empty? && !g_opts.lang_list.empty?
      puts "Error: --lang_list requires --json."
      exit 1
    end
    
#     repo_url, repo_name, vers_tag
#     target_list = []
#     # runtimes
#     unless g_opts.tag_list.empty?
#       target_list += g_opts.tag_list.split(/,\s*/).map do |e| 
#         ['https://github.com/tree-sitter/tree-sitter', 'tree-sitter', e]
#       end
#     end
    target_list = tag_targets(g_opts.tag_list)
    
    # langs
    unless g_opts.json.empty?
      lang_plan = JSON.parse(File.read(g_opts.json))
      # vet json structure!!!
      
      # whole lang plan
      lang_list = lang_plan.values
      
      # just a subset
      unless g_opts.lang_list.empty?
        # just this subset of lang_plan
        lang_list = g_opts.lang_list.split(/,\s*/).map do |e|
          info = lang_plan[e]
          unless info
            puts "No lang #{e} in #{g_opts.json}. Skipping."
            next nil
          end
          info
        end.compact
      end
      
      target_list += lang_list.map{|e| [e['url'], File.basename(e['url']), e['vers']]}
    end
    target_list
  end
  
  def repo_targets(lang_list, repo_dirs)
    # for langs, find highest tag we have cloned
    targets = lang_list.split(/,\s*/).map do |e| 
      repo_name = e.gsub(/_/, '-').gsub(/^/, 'tree-sitter-')
      repo_dir, vers_tag = most_recent(repo_name)
#       return repo_name unless repo_dir
      unless repo_dir
        "Missing repo #{e}. Skipping."
        next nil
      end
      [repo_dir, vers_tag, repo_name]
    end.compact
    
    # repo_dirs are specific
    targets += repo_dirs.split(/,\s*/).map do |e|
      unless Dir.exist?(e)
        "Missing repo #{e}. Skipping."
        next nil
      end
      repo_name, vers_tag = repo_dir.split(/\..*/)
      [e, vers_tag, repo_name]
    end.compact
  end
  
# ruby src/repo_runner.rb -i -l "bash" make_lang
# ruby src/repo_runner.rb -i -t "0.20.0" make_runtime

  def do_the_thing(g_opts, cmd, c_opts)
    puts `date`
    puts '+=+=+=+=+'
    
    # Do any cmd that DOESN'T need to be run in workdir/ and return
    case cmd
    when 'list_lang_repos'
      return list_lang_repos
    end
    
    puts "g_opts:"
    ap g_opts
    
=begin
    if g_opts.json.empty? && !g_opts.lang_list.empty?
      puts "Error: --lang_list requires --json."
      exit 1
    end
    
#     repo_url, repo_name, vers_tag
    target_list = []
    # runtimes
    unless g_opts.tag_list.empty?
      target_list += g_opts.tag_list.split(/,\s*/).map do |e| 
        ['https://github.com/tree-sitter/tree-sitter', 'tree-sitter', e]
      end
    end
    target_list = tag_targets(g_opts)
    
    # langs
    unless g_opts.json.empty?
      lang_plan = JSON.parse(File.read(g_opts.json))
      # vet json structure!!!
      
      # whole lang plan
      lang_list = lang_plan.values
      
      # just a subset
      unless g_opts.lang_list.empty?
        # just this subset of lang_plan
        lang_list = g_opts.lang_list.split(/,\s*/).map do |e|
          info = lang_plan[e]
          unless info
            puts "No lang #{e} in #{g_opts.json}. Skipping."
            next nil
          end
          info
        end.compact
      end
      
      target_list += lang_list.map{|e| [e['url'], File.basename(e['url']), e['vers']]}
    end
=end        
    puts "workdir: #{g_opts.workdir}+++"
    # DOES NOT prevent womping anything in workdir/
    FileUtils.mkdir_p(g_opts.workdir)
    FileUtils.cd(g_opts.workdir)
    puts "RepoRunner cmd: #{cmd.inspect}, g_opts: #{g_opts.inspect}"
    cmdline = case cmd
    when 'try'
      puts "try: moving to ../ztmp..."
      FileUtils.cd('../ztmp')
      runtime_repo = 'tree-sitter.0.20.0'
      make_one_lib(g_opts, runtime_repo)
      lang_repo = 'tree-sitter-bash.0.19.0'
      make_one_lib(g_opts, lang_repo)
      
    when 'clean_libs'
      Dir.children(Dir.pwd).each do |repo|
        puts "clean_libs #{repo}"
        puts `rm #{repo}/*/*.a #{repo}/*/*.dylib`
        # and generated .h, .pc if any
        proj_name = repo.gsub(/\..*/, '').tr('-', '_')
        puts `rm #{repo}/*/#{proj_name}.h #{repo}/*/#{proj_name}.pc`
      end
    when 'make_lang' 
      g_opts.lang_list.split(/,\s*/).each do |lang_repo| 
        repo = lang_repo.gsub(/^tree-sitter-/, '').gsub(/^/, 'tree-sitter-')
        repo_name = make_lang(g_opts, repo)
        puts "Couldn't find vers_tag for #{repo_name}. Skipped." if repo_name
      end
    when 'make_runtime' 
      g_opts.tag_list.split(/,\s*/).each do |vers_tag| 
        make_runtime(g_opts, "tree-sitter.#{vers_tag}")
      end
    when 'clone_lang'
      g_opts.lang_list.split(/,\s*/).each do |lang_repo|
        repo = lang_repo.gsub(/^tree-sitter-/, '').gsub(/^/, 'tree-sitter-')
        repo_dir = clone_lang(lang_repo)
        puts "#{repo_dir} exists. Skipped." if repo_dir
      end
      
    when 'clone'
      target_list = clone_targets(g_opts)
      ap target_list
      target_list.each do |url, name, vers|
        clone_repo(url, name, vers)
      end
    when 'make'
      tag_list = tag_targets(g_opts.tag_list)
      puts "make tag_list"
      ap tag_list
      tag_list.each do |url, name, vers|
        make_lib(g_opts, "#{name}.#{vers}", name)
      end
      repo_list = repo_targets(g_opts.lang_list, g_opts.repo_dirs)
      puts "make repo_list"
      ap repo_list
      repo_list.each do |repo_dir, vers, name|
        make_lib(g_opts, repo_dir, name)
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
    when 'make_lang_core' 
      lang_core.keys.each do |lang_repo|
#       g_opts.lang_list.split(/,\s*/).each do |lang_repo| 
        repo = lang_repo.to_s.tr('_', '-').gsub(/^tree-sitter-/, '').gsub(/^/, 'tree-sitter-')
        repo_name = make_lang(g_opts, repo)
        puts "Couldn't find vers_tag for #{repo_name}" if repo_name
      end
    when 'noop'
      puts "Ok, doing nothing."
    end
    FileUtils.cd('..')
    puts "done."
  end

  
end

RepoRunner.go(__FILE__)
