require 'include.rb'

RSpec.describe Parser do

  context "accepts and rejects" do
    subject { described_class }

    let(:main) do
      "
        void main(void) { }
      "
    end

    let(:function_decs) do
      "
        void f(int x) { }
        int main(void) { }
      "
    end

    let(:no_main) do
      "
        int main;
        void f(void) {}
      "
    end

    let(:no_main_trick) do
      "
        int hi;
        void f(void) { 
            int main;
        }
      "
    end

    let(:inputs) do
      [
        # [ TEST_NUMBER, TEST_CODE, EXPECTED_RESULT],
        [0  , main             , "ACCEPT" ],
        [1  , function_decs    , "ACCEPT" ],
        [2  , no_main          , "REJECT" ],
        [3  , no_main_trick    , "REJECT" ],
      ]
    end

    # "

    it "accepts and rejects" do
      inputs.each do |number, code, result, debug_level|
        f = File.open("test", 'w+')
        f.write(code)
        f.rewind
        if (string = parse(f)) != result
          puts number.to_s + " FAILED"
        end
        expect(string).to eq result
        f.close
      end
      File.delete("test")
    end
  end
end
