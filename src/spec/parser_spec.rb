require 'include.rb'

RSpec.describe Parser do

  context "accepts and rejects" do
    subject { described_class }

    let(:function_decs) do
      "
        int a[2];

        int b;
      int main(void) {}
      float f(int x) {}

      void g( void) {};
      "
    end

    let(:func_and_var) do
      "
      int main(int a, float b, int c) {
      }

      int a;
      int f(float x) {

      }
      "
    end

    let(:if_statements) do
      "
      float main(void) {
      if(a==b)
        return 1 + 2;
       else
        return 1 > 2;
      }"
    end

    let(:multiply) do
      "
      int main(void) {
        result = a * b * (12* (23/c));
      }

      int f(float x, float y) {
        asdflkjsadlfkj = 12.231 * 2.1;
      }
      "
    end

    let(:add) do
      "
      int main(void) {
        result = a + b - (12+ (23-c));
      }

      int f(float x, float y) {
        asdflkjsadlfkj = 12.231 + 2.1;
      }
      "
    end

    let(:invalid1) do
      "
      int f(void) {
        int g(void) {
        }
      }
      "
    end

    let(:must_have_params) do
      "
      int main() {
      }
      "
    end

    let(:valid_compares) do
      "
      int main(void) {
        int a;
        float c;
        b[0] = 3;
        c = b[21];
        if(a[1] == f)
          if (g [1] == h[3]) return;
          else
            return 1+1;
      }
      "
    end

    let(:nested_ifs) do
      "
      int main(void) {
        if(3.2 == 1.2)
          return;
        else
          if(40.2 == 12E03)
            a = 23;
          else
            a = 23;
      }
      "
    end

    let(:addition) do
      "
      int main (void){
        a = 1 + 1;
        a = (1 + 1);
        a = (1 + 1)-(23*2);
        a = ((1 + 1)-(23*2))*31+85;
      }
      "
    end

    let(:arrays) do
      "
      int main(void) {
        int b[0];
        int asdfasdfslkdjf[2333];
      }
      "
    end

    let(:function_calls) do
      "
      int main(void) {
        f();
        f(x);
        f(x, y, z);
      }"
    end

    let(:function_call2) do
      "
      int main(void) {
        f(a[2.2], b[3], 3 == 3);
      }
      "
    end

    let(:compute_god) do
      # This is the program from textbook pg: 496
      "
      /* A program to perform Euclid's
         Algorithm to compute god. */
      int god(int u, int v) {
        if(v == 0) return u;
        else return gcd(v, u-u / v*v);
        /* u-u/v*v == u mod v */
      }

      void main(void)
      { int x; int y;
        x = input(); y = input();
        output(gcd(x, y));
      }
      "
    end

    let(:sort_integers) do
      "
      /* A program to perform selection sort on a 10
         element array*/
      int x[10];

      int minloc( int a[], int low, int high)
      { int i; int x; int k;
        k = low;
        x = a[low];
        i = low + 1;
        while( i < high) {
          if(a[i] < x) {
            x = a[i];
            k = i;
          }
          i = i + 1;
        }
        return k;
      }

      void sort(int a[], int lwo, int high) {
        int i; int k;
        i = low;
        while(i < high-1) {
          int t;
          k = minloc(a, i, high);
          t = a[k];
          a[k] = a[i];
          a[i] = t;
          i = i + 1;
        }
      }
      void main(void)
      {
        int i;
        i = 0;
        while(i < 10) {
          x[i] = input();
          i = i + 1;
        }
        sort(x, 0, 10);
        i = 0;
        while(i < 10) {
          output(x[i]);
          i = i + 1;
        }
      }
      "
    end

    let(:jake_sample1) do
      "
        int main(int x, float joe) {
            int x;
            float y;
            void z;

            if (1) {
                void a;
                float b;
            } else {
                while(5) {
                    int x;
                    float a;
                    x = a + 5;
                    ;;;;;;;;;;;;;;;;;;;;;;;
                }
            }
            ;;;;;;;;;;;;;;;;;;;;;;
            y = 5 * 7 / x + 64 * 8;
            x = sqrt(64) + (5 * 7) / (9 + nickdaman);
            ;;;;;;;;;;;;;;;
            return sqrt(64);
            ;;;;
        }
      "
    end

    let(:jake_sample2) do
      "
        void main(int arg, float martino) {
            printf(5, 7, hello);
            return 5 + 7;
            x;
        }
      "
    end

    let(:almost_correct) do
      "
      int main(void) {
        return 5+7++;
      }
      "
    end

    let(:only_if) do
      "
      if(0) {
        printf(1+1); // reject because statement without func
      }
      "
    end

    let(:comments) do
      '
      // comment!
      int main(void) {//{ { {

        foo();
      }
      '
    end

    let(:no_curly) do
      "
      int main(void) {
      }
      float foo(int x)
        return stuff;
      "
    end

    let(:bad_param1) do
      "
      int a(int[2] a) { // [2] is not allowed here
      }
      "
    end

    let(:bad_param2) do
      "
      int a(int[] a;) {
      }
      "
    end

    let(:blah) do
      "
      int main(void) {
        if(1) return; else return 1.2;
      }
      "

    end

    let(:inputs) do
      [
        # [ TEST_NUMBER, TEST_CODE, EXPECTED_RESULT],
        [0  , "int a[1.2];"    , "ACCEPT" ],
        [1  , "int b"          , "REJECT" ],
        [2  , "b b"            , "REJECT" ],
        [3  , "b b(void)"      , "REJECT" ],
        [4  , "int b(void){}"  , "ACCEPT" ],
        [5  , "f(void)"        , "REJECT" ],
        [6  , function_decs    , "REJECT" ],
        [7  , invalid1         , "REJECT" ],
        [8  , if_statements    , "ACCEPT" ],
        [9  , func_and_var     , "ACCEPT" ],
        [10 , valid_compares   , "ACCEPT" ],
        [11 , addition         , "ACCEPT" ],
        [12 , arrays           , "ACCEPT" ],
        [13 , nested_ifs       , "ACCEPT" ],
        [14 , multiply         , "ACCEPT" ],
        [15 , add              , "ACCEPT" ],
        [16 , function_calls   , "ACCEPT" ],
        [17 , must_have_params , "REJECT" ],
        [18 , compute_god      , "ACCEPT" ],
        [19 , sort_integers    , "ACCEPT" ],
        [20 , jake_sample1     , "ACCEPT" ],
        [21 , jake_sample2     , "ACCEPT" ],
        [22 , almost_correct   , "REJECT" ],
        [23 , only_if          , "REJECT" ],
        [24 , comments         , "ACCEPT" ],
        [25 , no_curly         , "REJECT" ],
        [26 , bad_param1       , "REJECT" ],
        [27 , bad_param2       , "REJECT" ],
        [28 , function_call2   , "ACCEPT" ],
        [29 , blah             , "ACCEPT" ],
      ]
    end

    # "

    it "accepts and rejects" do
      inputs.each do |number, code, result, debug_level|
        f = File.open("parser.tst", 'w+')
        f.write(code)
        f.rewind
        if (string = parse(f)) != result
          puts number.to_s + " FAILED"
        end
        expect(string).to eq result
        f.close
      end
      File.delete("parser.tst")
    end
  end
end
