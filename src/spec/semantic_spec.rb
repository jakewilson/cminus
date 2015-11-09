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

    let(:undeclared_var) do
      "
        int main(void) {
            int y;
            x = y + 5;
        }
      "
    end

    let(:declared_var) do
      "
        int main(void) {
            int y;
            y = y + 5;
        }
      "
    end

    let(:undeclared_var1) do
      "
        int main(void) {
            int y;
            int x;
            float z;
            y = y + 5;
            z = 9.0;
            x = a + 67; // 'a' should cause a failure
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
        [4  , undeclared_var   , "REJECT" ],
        [5  , declared_var     , "ACCEPT" ],
        [6  , undeclared_var1  , "REJECT" ],
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
