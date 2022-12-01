require 'fileutils'

require 'date'

puts `date`
puts '=+=+=+=+='
puts


# lang_core_repos = ["tree-sitter-bash", "tree-sitter-python", "tree-sitter-html", "tree-sitter-rust", "tree-sitter-wasm", "tree-sitter-markdown", "tree-sitter-typescript", "tree-sitter-cpp", "tree-sitter-c", "tree-sitter-ruby", "tree-sitter-embedded-template", "tree-sitter-javascript", "tree-sitter-sexp", "tree-sitter-make", "tree-sitter-json", "tree-sitter-c-sharp"]
# 
# # lang_tiny = ["tree-sitter-json"]
# lang_tiny = ["tree-sitter-c"]

# call this script from within daystamped tree-sitter-lang dir

# option --generic for force using the general makefile, even if there's one in the repo?
# check for case-insensitive Makefile!!!

# nope, option --makefile to use custom makefile in repo -- currently doesn't shunt!!!
# option --build-only???

vers_tags = ["0.20.0", "0.20.6", "0.20.7"]
# vers_tags = ["0.20.0"]

def byo_makefile
  Dir.children(Dir.pwd).map(&:upcase).include?('MAKEFILE')
end

def make(repo, install=false)
#   relpath_to_makefile = '../../src/Makefile-runtime' ### langs from tree-sitter-lang/
  relpath_to_makefile = '../../src/Makefile-runtime'
  FileUtils.cd(repo)
  FileUtils.cd('tree-sitter')
  puts "in #{Dir.pwd}"
  call = 'make'
  call += ' --debug' # for verbose
  call += case install
  when :install then ' install'
  when :install_and_symlink then ' install-and-symlink'
  else
    ''
  end
#   call += ' install' if install && install == :install
#   call += ' install-and-symlink' if install && install == :install_and_symlink
  call += " -f #{relpath_to_makefile}" ###unless byo_makefile # use shunting for now!!!
#   call += " -f #{relpath_to_makefile}" unless byo_makefile
  puts "  `#{call}`"
  puts `#{call}`
  FileUtils.cd('../..')
end

vers_tags.each do |vers_tag| 
  repo = "tree-sitter-v#{vers_tag}"
  puts "=== #{repo}"
#   make(repo, :install_and_symlink)
  make(repo, :install)
#   make(repo)
end

best_vers_tag = "0.20.7"
repo = "tree-sitter-v#{best_vers_tag}"
make(repo, :install_and_symlink)

### control all the install, symlink etc from RepoRunner with opts!!! FIXME!!!