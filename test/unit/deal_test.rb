require 'test_helper'

class DealTest < ActiveSupport::TestCase
  test "factory should be sane" do
    assert FactoryGirl.build(:deal).valid?
  end

# TPP - changed 0.01 to 1.second
  test "1 over should be less than current time" do
    deal = FactoryGirl.create(:deal, :end_at => Time.zone.now + 1.second)
    assert !deal.over?, "Deal should not be over"
    sleep 1
    assert deal.over?, "Deal should be over"
  end  

end
