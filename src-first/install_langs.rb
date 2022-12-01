require 'fileutils'

require 'date'

puts `date`
puts '=+=+=+=+='
puts

lang_core_repos = ["tree-sitter-bash", "tree-sitter-python", "tree-sitter-html", "tree-sitter-rust", "tree-sitter-wasm", "tree-sitter-markdown", "tree-sitter-typescript", "tree-sitter-cpp", "tree-sitter-c", "tree-sitter-ruby", "tree-sitter-embedded-template", "tree-sitter-javascript", "tree-sitter-sexp", "tree-sitter-make", "tree-sitter-json", "tree-sitter-c-sharp"]

# lang_tiny = ["tree-sitter-json"]
lang_tiny = ["tree-sitter-c"]

# call this script from within daystamped tree-sitter-lang dir

def make(repo, install=false)
  relpath_to_makefile = '../../src/Makefile-shunt'
#   relpath_to_makefile = '../../src/Makefile-lang'
  FileUtils.cd(repo)
  call = 'make'
  call += ' --debug' # for verbose
  call += ' install' if install
  call += " -f #{relpath_to_makefile}" unless Dir.children(Dir.pwd).include?('Makefile')
  puts "  `#{call}`"
  puts `#{call}`
  FileUtils.cd('..')
end

lang_core_repos.each do |repo| 
  puts "=== #{repo}"
  make(repo, :install)
#   make(repo)
end
