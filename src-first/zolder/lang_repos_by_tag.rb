require './src/lang_lists.rb'

require 'date'
require 'fileutils'

# daystamp for uniq dir name
def letter_of_the_week(num) 'nmtwrfs'.chars[num % 7] || "" end
def date_day_time(dt=DateTime.now)
	alpha = letter_of_the_week(dt.wday)
	dt.strftime("%Y%m%d#{alpha}-%H%M")
end
def daystamp(dt=DateTime.now) date_day_time(dt)[2..-1] end
def daysubsq(dt=DateTime.now)
	alpha = letter_of_the_week(dt.wday)
	dt.strftime("-%H%M#{alpha}")
end
# full date_day_time: /\d\d\d\d\d\d[nmtwrfs]-\d\d\d\d/
# shorter daystamp: /\d\d\d\d\d\d\d\d[nmtwrfs]-\d\d\d\d/
# subsq on the same day: /-\d\d\d\d[nmtwrfs]/

# a few langs for script testing...
lang_tiny = {
	c: "https://github.com/tree-sitter/tree-sitter-c",
	json: "https://github.com/tree-sitter/tree-sitter-json",
	embedded_template: "https://github.com/tree-sitter/tree-sitter-embedded-template",
}


### argh less but still taggy!!!
# daystamp the lang outer dir!!!
outer_dir = "tree-sitter-lang-#{daystamp}"
FileUtils.mkdir_p(outer_dir)
FileUtils.cd(outer_dir)
puts "=== #{outer_dir}"
# lang_tiny.each do |lang_key, repo_url|
lang_core.each do |lang_key, repo_url|
  repo_name = repo_url.split('/').last
  # get the latest tag
  tag = `git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' #{repo_url} \
    | tail -n1 | cut -d/ -f3`.gsub(/\^\{\}$/, '').chomp
#   repo_dir = "#{repo_name}-#{tag}"
#   FileUtils.mkdir_p(repo_dir)
#   FileUtils.cd(repo_dir)
#   call = "git clone -b #{tag} --depth 1 #{repo_url}.git"
#   puts call
#   `#{call}`
  `git clone -b #{tag} --depth 1 #{repo_url}.git`
end
FileUtils.cd('..')



vers = '0.3.3'

# for lang repos, pull latest tag but number the shunt dir as 0.3.3

# daystamp the lang outer dir!!!
# outer_dir = "tree-sitter-lang-#{cal_stamp}"
# FileUtils.mkdir_p(outer_dir)
# FileUtils.cd(outer_dir)
# puts "=== #{outer_dir}"
# lang_tiny.each do |lang_key, repo_url|
#   repo_name = repo_url.split('/').last
#   # get the latest tag
#   tag = `git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' #{repo_url} \
#     | tail -n1 | cut -d/ -f3`.gsub(/\^\{\}$/, '').chomp
#   repo_dir = "#{repo_name}-#{tag}"
#   FileUtils.mkdir_p(repo_dir)
#   FileUtils.cd(repo_dir)
#   puts repo_url.inspect
# #   puts "in #{FileUtils.pwd}"
#   call = "git clone -b #{tag} --depth 1 #{repo_url}.git"
#   puts call
#   `#{call}`
# #   `git clone -b #{tag} --depth 1 #{repo_url}.git`
#   FileUtils.cd('..')
# end


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
#   # not useful currently (bc headless???). just do git log by hand as nec
#   files = `git ls-tree -r --name-only #{tag}`.split("\n")
#   file_times = files.map do |filename|
#     [filename, `git log -1 --format="%ad" -- #{filename}`]
#   end
#   puts file_times.inspect
# 
#   FileUtils.cd('..')
# end
# FileUtils.cd('..')



# TSLANG=embedded-template
# git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/tree-sitter/tree-sitter-$TSLANG | tail -n1 | cut -d/ -f3
# 
# git log -1 --format="%ad" -- README.md
# 
# git ls-tree -r --name-only v0.20.2