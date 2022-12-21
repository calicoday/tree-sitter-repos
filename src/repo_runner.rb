require './src/util/optimist.rb'
require './src/util/sunny.rb'

# for list_lang_repos to web scrape tree-sitter.github.io source file index.md for langs
require 'open-uri'

# for src/lang_repos.json and repos/cloned_repos.json
require 'json'

require 'fileutils'
require 'awesome_print'

class RepoRunner < Sunny
#   attr_reader :vers, :thaw
  attr_reader :lang_core
  
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
      "list_lang_repos" => "Create 'src/lang_repos.json', listing each of the language repos listed in the tree-sitter.github.io section Introduction: Available Parsers",
      "clone" => "Git clone repos from github",
      "make" => "Make cloned repos",
      "dev" => "No-op for repo_runner.rb options testing",
      }
    # vet cmd_list for matching method, if we're going to blindly redirect!!!
    cmd_opts = Proc.new {|cmd|
      }
    g_opts, cmd, c_opts = ready(cmd_list.keys, cmd_opts) do 
      version 'repo_runner.rb v0.0.1'
      banner("Runner of tree-sitter-repo scripts")
      banner "\nUsage:"
      banner "  repo_runner.rb [options] <command>"
      banner "\nOptions:"
      # -v, -h get added auto but they land after the subcommands, so put them here
      opt(:version)
      opt(:help)
      
      # input:
      opt(:tag_list, "Tags (eg '0.20.7') of runtime versions to process, comma-separated", 
        :default => '', :type => String)
      # (clone) --json is required if --lang_list or --core_langs!!!
      opt(:json, "(clone) JSON lang info file with a list of repos and versions, keyed by short name. See notes",
        :default => '', :type => String)
      opt(:lang_list, "Short names (eg 'bash' for 'tree-sitter-bash') of lang repos to process, comma-separated. For clone, requires --json. See notes", 
        :type => String) # no dflt, must pass '' for all langs
      
      opt(:repo_dirs, "Versioned repo dirs, separated by comma (eg 'tree-sitter-bash.0.19.0')", 
        :default => '', :type => String)      
      opt(:core_langs, "Use the core lang list. For clone, requires --json. See notes") 
      opt(:workdir, "Working directory for cloned/built repos", 
        :default => 'repos/', :type => String)

      
      banner "  additional options for make:"
      opt(:debug, "Pass --debug option to make for verbose output")
      opt(:noop, "Pass --noop option to make for dry run")
      opt(:install, "Install lib in the conventional sys dir")
      opt(:alias, "Create a symlink to the installed lib with the simple, non-versioned name (use rarely and deliberately)")
      
      banner "\nCommands:"
      # Optimist doesn't wrap desc, use max 80
      offset = 2 + 20 + 1
      col2_w = 80 - (offset)
      cmd_list.each do |cmd, desc| 
        # strip frags so \n takes the place of any trailing \w
        frags = desc.scan(/.{1,#{col2_w}}\b|..{1,#{col2_w}}/).map(&:strip)
        banner format("  %-20s %s", cmd, frags.join("\n#{' '*offset}"))        
      end
      
      banner "\nNotes:"
      banner "  - The core langs are all langs mentioned in the main tree-sitter repo "
      banner "    itself (in tests, documentation or examples), currently: bash, c, "
      banner "    c_sharp, cpp, javascript, json, make, markdown, python, ruby, rust, "
      banner "    sexp, typescript, wasm, embedded_template, html."
      
      banner "  - Use the --lang_list option to specify by short name a subset of langs "
      banner "    in a supplied --json lang info file."
      
      banner "  - The --json lang info file must have the structure from the top:"
      banner "      {"
      banner "        'lang': {"
      banner "          'url': 'https://github.com/org-name/tree-sitter-lang',"
      banner "          'vers': '3.4.5'"
      banner "        }"
      banner "       }"
      banner "    Other data intermingled will be ignored. The json file produced by "
      banner "    the list_lang_repos is suitable."
      
      banner "  - the --repo_dirs option takes a list of specific versioned repos in "
      banner "    the form repo_name.tag_version, eg 'tree-sitter.0.20.7' or "
      banner "    'tree-sitter-bash.0.19.0'"
      
      banner "\nSee https://github.com/calicoday/tree-sitter-repos for more information."
      banner ""
      
    end
    
    do_the_thing(g_opts, cmd, c_opts)
  end


  # make given specific repo_dir
  def make_lib(g_opts, repo_dir, repo_name=nil)
    # if no repo_name, use repo_dir up to the vers
#     puts "repo_dir: #{repo_dir}, repo_name: #{repo_name}"
    repo_name = repo_dir.gsub(/\..*/, '') unless repo_name
#     puts "  repo_name: #{repo_name}"
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

  def most_recent(repo_name)
    cand = list_shunt_dirs(repo_name)
    puts "^^^ most_recent repo_name: #{repo_name}"
    return nil if cand.empty?
    # numeric sort
    best_vers = 'untagged' if cand.length == 1 && cand[0] == "#{repo_name}.untagged"
    best_vers = cand.map{|e| e.split(/^#{repo_name}\./)}.map{|e| 
      e[1].split('.').map(&:to_i)}.sort.last.join('.') unless best_vers
    [shunt_dir(repo_name, best_vers), best_vers]
  end
  
  def git_clone(repo_url, vers_tag)
#   def git_clone(repo_url, vers_tag=nil)
    vers_tag ?
      `git clone -b v#{vers_tag} --depth 1 #{repo_url}.git` :
      `git clone #{repo_url}.git`
  end
  
  def  clone_repo(repo_url, repo_name, vers_tag)
    repo_dir = shunt_dir(repo_name, vers_tag)
    return repo_dir if Dir.exist?(repo_dir)
    
    repos_info = {}
    repos_info = JSON.parse(
      File.read('cloned_repos.json')) if File.exist?('cloned_repos.json')
    
    # get the commit from lang_deets, not relevant but harmless for tagged runtime 
    lang_name, deets = lang_deets(repo_url, nil, nil) ### refac!!!
    
    FileUtils.mkdir_p(repo_dir)     
    FileUtils.cd(repo_dir)
    
    git_clone(repo_url, vers_tag)
    
    # now map the dirs, add it to repos_info and rewrite cloned_repos.json
    parser_paths = Dir['**/*'].select{|e| !File.directory?(e) && e =~ /\bparser.c\b/}    
    repos_info[repo_dir] = {layout: parser_paths} # other info???
    # it will womp :layout if snap/untagged but we'll note the commit for ref
    repos_info[repo_dir][:commit] = deets[:commit] if deets[:vers] == 'untagged'
    repos_info[repo_dir][:date_cloned] = `date`

    FileUtils.cd('..')
    
    # write cloned_repos.json
    File.write('cloned_repos.json', JSON.pretty_generate(repos_info))
    
    nil # no news is good news
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

  # => [[repo_url, repo_name, vers]*]
  def clone_target_list(g_opts)
    target_list = tag_targets(g_opts.tag_list)
    return target_list unless (g_opts.lang_list || g_opts.core_langs)
    
    # we want some langs, do we have json?
    if g_opts.json.empty?
      puts "Error: --lang-list or --core-langs requires --json for clone."
      exit 1
    end

    lang_plan = JSON.parse(File.read(g_opts.json))
    # vet json structure!!!

    if g_opts.lang_list.empty?
      # whole json
      return target_list + 
        lang_plan.map{|k,v| [v['url'], File.basename(v['url']), v['vers']]}
    end
    
    gather = {}
    short_names = []
    short_names += g_opts.lang_list.split(/,\s*/) if g_opts.lang_list
    short_names += lang_core.keys.map(&:to_s) if g_opts.core_langs
    target_list += short_names.sort.uniq.map do |e|
      info = lang_plan[e]
      unless info
        puts "No lang #{e} in #{g_opts.json}. Skipping."
        next nil
      end
      [info['url'], File.basename(info['url']), info['vers']]
    end
    target_list
  end
  
  # => [[repo_dir, repo_name]*]
  def make_target_list(g_opts)
    # gather [repo_dir, repo_name, input], then conf each repo_dir exists and
    # use input for error msg. 
    target_list = tag_targets(g_opts.tag_list).map do |url, name, vers| 
      ["#{name}.#{vers}", name, vers]
    end
    
    short_names = []
    short_names += g_opts.lang_list.split(/,\s*/) if g_opts.lang_list
    short_names += lang_core.keys.map(&:to_s) if g_opts.core_langs
    # for langs, find highest tag we have cloned
    target_list += short_names.map do |e|
      repo_name = e.gsub(/_/, '-').gsub(/^/, 'tree-sitter-')
      repo_dir, vers_tag = most_recent(repo_name)
      [repo_dir, repo_name, e]
    end

    ### TMP!!! disabled!!!
    # repo_dirs are specific
#     target_list += g_opts.repo_dirs.split(/,\s*/).map do |repo_dir|
#       repo_name, vers_tag = repo_dir.split(/\..*/)
#       [repo_dir, repo_name, repo_dir]
#     end
      
    target_list.map do |repo_dir, repo_name, input|
      unless Dir.exist?(repo_dir)
        "Missing repo #{input}. Skipping."
        next nil
      end
      [repo_dir, repo_name]
    end.compact
  end
  
  def dev(g_opts, cmd, c_opts)
    puts "g_opts:"
    ap g_opts
    # always
    if !g_opts.json.empty? && !g_opts.lang_list
      puts "Error: --json requires --lang-list (pass '' to process all langs in file)."
    end
    # for clone:
    if g_opts.lang_list && g_opts.json.empty?
      puts "Error: --lang-list requires --json for clone."
    end
    puts
    puts "done."
#     exit 0
  end

  def do_the_thing(g_opts, cmd, c_opts)
    puts `date`
    puts '+=+=+=+=+'
    
    # Do any cmd that DOESN'T need to be run in workdir/ and return
    case cmd
    when 'list_lang_repos'
      return list_lang_repos
    when 'dev'
      return dev(g_opts, cmd, c_opts)
    end
    
    puts "g_opts:"
    ap g_opts
    
    if !g_opts.json.empty? && !g_opts.lang_list
      puts "Error: --json requires --lang-list (pass '' to process all langs in file)."
      exit 1
    end

    # DOES NOT prevent womping anything in workdir/
    FileUtils.mkdir_p(g_opts.workdir)
    FileUtils.cd(g_opts.workdir)
    puts "RepoRunner cmd: #{cmd.inspect}, g_opts: #{g_opts.inspect}"
    cmdline = case cmd
    when 'clone'
      clone_target_list(g_opts).map do |repo_url, repo_name, vers|
        clone_repo(repo_url, repo_name, vers)
      end
    when 'make'
      make_target_list(g_opts).map do |repo_dir, repo_name|
        make_lib(g_opts, repo_dir, repo_name)
      end
    end
    FileUtils.cd('..')
    puts "done."
  end

  
end

RepoRunner.go(__FILE__)
