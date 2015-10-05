##
# parser.rb
# Author: Jake Wilson
# Date: 10/4/15
##

class Parser
    def initialize(input)
        @input = input
        @token = Scanner.getToken(input)
        while @token.type != TokenType::EOF
            puts @token.type
            puts @token.val
            @token = Scanner.getToken(input)
        end
    end

    def parse
        
    end
end
