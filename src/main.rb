require_relative 'scanner.rb'

input = File.open(ARGV[0], 'r')

Scanner.getTokenType(input)
Scanner.getTokenType(input)
