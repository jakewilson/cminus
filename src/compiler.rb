class Compiler

    @@input = nil

    def initialize
        @@input = File.open($0, 'r')
    end

    def input
        @@input
    end

end

c = Compiler.new
c.input.each_line do |line|
    puts line
end
