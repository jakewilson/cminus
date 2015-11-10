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

    let(:void_param) do
      "
        void main(void x) {

        }
      "
    end

    let(:re_declaration) do
      "
        void main(void) {
            int a;
            int a;
            a = 5 + 7;
            return;
        }
      "
    end

    let(:valid_re_dec) do
      "
        void main(int hello) {
            int a;
            { int a; }
            a = 5 + 7;
            return;
        }
      "
    end

    let(:invalid_re_dec) do
      "
        void main(void) {
            int a;
            { int a; }
            int a;
            a = 5 + 7;
            return;
        }
      "
    end

    let(:param_re_dec) do
      "
        void main(int a, int b) {
            int a;
            int c;
            int d;
        }
      "
    end

    let(:param_re_dec1) do
      "
        void main(int a, int b) {
            int b;
            int c;
            int d;
        }
      "
    end

    let(:global_var) do
      "
        int a;
        void main(int b) {
            a = 5;
            return;
        }
      "
    end

    let(:nested_blocks) do
      "
        void main(int a) {
            {
                int a;
                {
                    int a;
                    {
                        int a;
                    }
                }
            }
        }
      "
    end

    let(:non_global) do
      "
        int a;
        void main(int b) {
            int c;
            a = 5;
            if (1) {
                c = 6;
                a = 7;
            }
        }
      "
    end

    let (:wrong_scope) do
      "
        int a;
        void f(int b) {
            a = b = 7;
        }

        void main(void) {
            b = 6;
        }
      "
    end

    let(:valid_re_dec1) do
      "
        void main(void) {
            int a;
            { int a; }
            a = 5 + 7;
            return;
        }
      "
    end

    let(:many) do
      "
        int a;
        void b(int c, int d) {
            int a;
            while (6) {
                int d;
                a = 7;
                if (1) {
                    d = 5;
                    c = 6;
                    a = 10;
                }
            }
        }

        void main(void) {
            int c;
            a = 61;
            { int c; }
            { int c; }
            c = 65;
            { int a; }
            a = 10;
        }
      "
    end

    let (:weird_global) do
      "
        int a;
        void b(void) {

        }

        int c;
        void main(void) {
            c = 5;
        }
      "
    end

    let (:valid_func_call) do
      "
        int a;
        int b(int c) {
            return 1;
        }

        void main(void) {
            b();
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
        [7  , void_param       , "REJECT" ],
        [8  , re_declaration   , "REJECT" ],
        [9  , valid_re_dec     , "ACCEPT" ],
        [10 , invalid_re_dec   , "REJECT" ],
        [11 , param_re_dec     , "REJECT" ],
        [12 , param_re_dec1    , "REJECT" ],
        [13 , global_var       , "ACCEPT" ],
        [14 , non_global       , "ACCEPT" ],
        [15 , wrong_scope      , "REJECT" ],
        [16 , valid_re_dec1    , "ACCEPT" ],
        [17 , many             , "ACCEPT" ],
        [18 , weird_global     , "ACCEPT" ],
        [19 , valid_func_call  , "REJECT" ],
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
