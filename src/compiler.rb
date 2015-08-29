require_relative 'scanner.rb'

class Compiler

    @@input = nil

    def initialize
        @@input = File.open(ARGV[0], 'r')
    end

    def input
        @@input
    end

end

c = Compiler.new
s = Scanner.new
s.getTokenType(c.input)
