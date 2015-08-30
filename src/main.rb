# main.rb
#
# Author: Jake Wilson
# Date: 08/29/15
# 

require_relative 'scanner.rb'
require_relative 'types.rb'

input = File.open(ARGV[0], 'r')

while (ret = Scanner.getTokenType(input)) != TokenType::EOF
    if ret == TokenType::ERROR
        puts "error"
    end
end
