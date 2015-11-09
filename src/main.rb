# main.rb
#
# Author: Jake Wilson
# Date: 08/29/15
# 

$debug = false

require "./types.rb"
require "./scanner.rb"
require "./parser.rb"
require "./symbol_table.rb"

def parse(input)
    parser = Parser.new(input)
    begin
        parser.parse
        parser.match(TokenType::EOF)
        return "ACCEPT"
    rescue Reject
        return "REJECT"
    end
end

if ARGV.count ==  0 
    puts "Error: No file name supplied"
    exit 1
end
 
if !File.exists? ARGV[0]
    puts ARGV[0] + " does not exist"
    exit 1
end

# If more than one argument is supplied, turn the debug flag on
if ARGV.count >= 2
    $debug = true
end

input = File.open(ARGV[0], 'r')

Scanner.entire_file = input.readlines
input.rewind

puts parse(input)
