# this isn't useful currently when pulling a specific tag (bc headless???)

require 'fileutils'

top = Dir.pwd
Dir.children(top).map do |kid|
  next unless File.directory?(kid)
  puts kid.inspect
  tag = kid[kid.index(/v[\d\.]*$/)..-1]
  puts tag.inspect
#   next
  
  FileUtils.cd(kid)
  raise "#{kid} has too many children!!" unless Dir.children(Dir.pwd).length == 1
  lang_repo = Dir.children(Dir.pwd).first
  FileUtils.cd(lang_repo)
  files = `git ls-tree -r --name-only HEAD`.split("\n")
#   files = `git ls-tree -r --name-only #{tag}`.split("\n")
  mod_times = files.map do |filename|
    [filename, `git log -1 --format="%ad" #{filename}`.chomp]
#     [filename, `git log -1 --format="%ad" -- #{filename}`.chomp]
#     [filename, `git log -1 --format="%ai" -- #{filename}`.chomp]
  end
  puts "=== #{lang_repo}..."
  mod_times.each do |name, stamp|
    puts "#{stamp}\t#{name}"
  end
  FileUtils.cd('../..')
end


# outer_dir = "tree-sitter-lang-221116w-1308"
# FileUtils.cd(outer_dir)
# puts "=== #{outer_dir}"
# lang_tiny.each do |lang_key, repo_url|
#   repo_name = repo_url.split('/').last
#   # get the latest tag; assume any ^{} points to a valid tag and just cut it
#   tag = `git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' #{repo_url} \
#     | tail -n1 | cut -d/ -f3`.gsub(/\^\{\}$/, '').chomp
#   repo_dir = "#{repo_name}-#{tag}"
#   FileUtils.cd(repo_dir)
# 
#   ### now make a list of the file mod dates of each file in the tagged repo
#   files = `git ls-tree -r --name-only #{tag}`.split("\n")
#   file_times = files.map do |filename|
#     [filename, `git log -1 --format="%ad" -- #{filename}`]
#   end
#   puts file_times.inspect
# 
#   FileUtils.cd('..')
# end
# FileUtils.cd('..')
# 
# 
# 
# # TSLANG=embedded-template
# # git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/tree-sitter/tree-sitter-$TSLANG | tail -n1 | cut -d/ -f3
# 
# 
# git log -1 --format="%ad" -- README.md
# 
# 
# git ls-tree -r --name-only v0.20.2