##
# parser.rb
# Author: Jake Wilson
# Date: 10/4/15
##

class Parser
    def initialize(input)
        puts "parsing it up"
        @input = input
        @token = Scanner.getToken(input)
    end
end
