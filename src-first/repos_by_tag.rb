require './src/date_day_time.rb'

require 'fileutils'


repo_tags = ["v0.20.0", "v0.20.6", "v0.20.7"]
org_name = "tree-sitter"
repo_name = "tree-sitter"
repo_url = "http://github.com/#{org_name}/#{repo_name}"

# script_dir = FileUtils.pwd
repo_tags.each do |tag|
  repo_dir = "#{repo_name}-#{tag}"
  if Dir.exist?(repo_dir)
    puts "#=== {repo_dir} exists. skipping."
    next
  end
  FileUtils.mkdir_p(repo_dir)
  FileUtils.cd(repo_dir) 
  puts "=== #{repo_url}"
  `git clone -b #{tag} --depth 1 #{repo_url}.git`
  FileUtils.cd('..')
end

