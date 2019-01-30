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
      #fi.pv(0.005,240,-2098.43,1000,0).round(2).should == 292598.38
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
    it 'returns .12' do
      fi.irr(-93109.0,11526.0,25970.0,53626.0,38964.0).round(3).should == 0.123
    end
    it 'returns .0792' do
      fi.irr(-100000.0, 10000, 25000.0, 50000, 40000).round(4).should == 0.0792
    end

    it 'works for many cash flows' do
      fi.irr(-10000, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100, 2200).round(4).should == 0.1073
    end
    it 'does large cash flows' do
      fi.irr( -100000, 20000, 21000, 21100, 21200, 21300, 21400, 21500, 21600, 21700, 21800, 21900, 22000, 22100 ).round(4).should == 0.1889
    end

    it 'does other long ones' do
      fi.irr( -989.12, 37.25, 37.25, 37.25, 37.25, 37.25, 37.25, 37.25, 37.25, 37.25, 37.25, 37.25, 37.25, 37.25, 1037.25, ).round(4).should == 0.0383
    end

    it 'brate' do
      fi.irr( -989.12, 37.25, 37.25, 37.25, 1037.25, ).round(4).should == 0.0402
      fi.brate( -989.12, 37.25, 4.0, 1000).round(4).should == 0.0402
    end

    it 'a stock example' do
      fi.irr(-98198.00, 11893.00, 25571.00, 50319.00, 39965.00).round(4).should == 0.0954
    end

    it 'does another example' do
      fi.irr(-85768.00, 11673.00, 25611.00, 54064.00, 38769.00 ).round(4).should == 0.1570
    end

    it 'another negative example' do
      fi.irr(-85061.00,  10782.00, 25564.00, 52392.00, 39036.00 ).round(4).should == 0.1520
    end
  end

  describe ".fvrate & .pvrate" do
    # 39 years
    # 11,000 payment
    # 3,000,000 FV
    it 'should be 8.52%' do
      r = fi.fvrate(39, 11_000, 3_000_000)
      expect(r).to eq 0.0852
    end

    it 'should be %2.52' do
      r = fi.pvrate(40, 4000, 100000)
      expect(r).to eq 0.025244
    end

    it '' do
      #$28,000 = (350/r) * (1 - (1/ (1+r))^120)
      r = fi.pvrate(120, 350, 28000)
      expect(r).to eq 0.007241
    end
  end
end
