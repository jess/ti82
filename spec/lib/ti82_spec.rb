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

  describe ".pv" do
    it 'returns the present value' do
      fi.pv(0.005,240,-2098.43,1000,0).round(2).should == 292598.38
    end

    it 'when the fv is 0' do
      fi.pv(0.005,240,-2098.43,0,0).round(2).should == 292900.48
    end
  end

  describe ".npv" do
    it 'returns 2368.87' do
      fi.npv(0.05, 100, 1000, 500, 999).round(2).should == 2368.87
    end

    it ' returns 1461.84' do
      fi.npv(0.05, 100, 1000, -500, 999).round(2).should == 1461.84
    end
  end

  describe ".irr" do
    it 'returns .0792' do
      fi.irr(-100000, 10000, 25000, 50000, 40000).round(4).should == 0.0792
    end
  end
end
