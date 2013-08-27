require 'ti82'
require 'pry'
class Fi
  include Ti82
end
describe Ti82 do
  let(:fi){ Fi.new }

  describe ".pmt" do
    context "using normal end of period" do
      it 'calculates the correct payment' do
        fi.pmt(0.003, 360, 400000, 0).round(2).should == 1818.58
        fi.pmt(0.03, 100, -3000, 1676255.73).round(2).should == 2665.29
      end
    end

    context "payments made at begining of period" do
      it 'gives correct answer' do
        fi.pmt(0.08,28,0,4500000,1).round(0).should == 43704
        fi.pmt(0.08,23,0,4500000,1).round(0).should == 68426
      end
    end
  end
end
