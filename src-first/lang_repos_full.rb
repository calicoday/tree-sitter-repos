# require './src/lang_lists.rb'

require 'date'
require 'fileutils'
require './date_day_time.rb'

# a few langs for script testing...
lang_tiny = {
	c: "https://github.com/tree-sitter/tree-sitter-c",
	json: "https://github.com/tree-sitter/tree-sitter-json",
	embedded_template: "https://github.com/tree-sitter/tree-sitter-embedded-template",
}

# make lang_lists.json??? FIXME!!!

lang_core = {
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


### for now just pull each lang into a daystamped outer dir and skip versioning!!!
# get versioning in and drop daystamp???!!!

# daystamp the lang outer dir!!!
outer_dir = "tree-sitter-lang-#{daystamp}"
FileUtils.mkdir_p(outer_dir)
FileUtils.cd(outer_dir)
puts "=== #{outer_dir}"
# lang_tiny.each do |lang_key, repo_url|
last_log = lang_core.map do |lang_key, repo_url|
  `git clone #{repo_url}.git`
  # collect last log entry for repo -- untested!!! FIXME!!!
  repo_name = repo_url.split('/').last
  FileUtils.cd(repo_name)
  log = `git log -1`
  FileUtils.cd('..')
  [repo_name, log]
end.to_h
FileUtils.cd('..')

# into file:
# puts last_log.map{|k,v| ["\n\n=== #{k}\n\n", v]}.flatten.join

# preface with "Last git log entry for each repo.\n"