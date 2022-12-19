require 'open-uri'
require 'awesome_print'

def lang_entry(s)
  s.gsub(/^[^\[]*\[([^\]]*)\].*(tree-sitter-[^\)]*)\).*/, '\2: \1')
end
def gather_langs(chunk)
  chunk.split("\n").
    map{|e| lang_entry(e)}.
    map{|e| e.split(': ')}.
    reject{|e| e.length != 2}.to_h
end
# s = open('https://tree-sitter.github.io/tree-sitter/').read
# s = open('https://github.com/tree-sitter/tree-sitter/blob/master/docs/index.md').read
s = open('https://raw.githubusercontent.com/tree-sitter/tree-sitter/master/docs/index.md').read

# puts s
chunks = s.split(/(Parsers for these languages are fairly complete:|Parsers for these languages are in development:|Talks on Tree-sitter)/)

# ap chunks.map{|e| e[0..100]}
complete = chunks[2]
dev = chunks[4]

puts "complete"
ap gather_langs(chunks[2])
# puts complete
# ap complete.split("\n").map{|e| lang_entry(e)}
# ap complete.split("\n").
#   map{|e| e.gsub(/^.*(tree-sitter-\w+)[^>]*>([^<]*).*/, '\1: \2')}.
#   map{|e| e.split(': ')}.
#   reject{|e| e.length < 2}.to_h

puts "dev"
ap gather_langs(chunks[4])
# puts dev #.split("\n\n").first
# ap dev.split("\n").map{|e| lang_entry(e)}
# ap dev.split("\n").
#   map{|e| e.gsub(/^.*(tree-sitter-\w+)[^>]*>([^<]*).*/, '\1: \2')}.
#   map{|e| e.split(': ')}.
#   reject{|e| e.length < 2}.to_h


puts
puts "done."