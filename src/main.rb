# main.rb
#
# Author: Jake Wilson
# Date: 08/29/15
# 
#

$debug = false

require "./scanner.rb"
require "./types.rb"

if !File.exists? ARGV[0]
    puts ARGV[0] + " does not exist"
    exit 1
end

if ARGV.count >= 2
    $debug = true
end

input = File.open(ARGV[0], 'r')

Scanner.entire_file = input.readlines
input.rewind

while (ret = Scanner.getTokenType(input)) != TokenType::EOF

end
