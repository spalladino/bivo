require 'test_helper'

class CharityTest < ActiveSupport::TestCase

  test "should get charities with cause data" do
    charity = Charity.make
    [20,10,40].each do |votes|
      Cause.make_with_votes :votes_count => votes, :charity => charity, :funds_raised => 100.0
    end

    charities = Charity.with_cause_data.all
    assert_not_nil charities
    assert_equal 1, charities.size
    assert_equal charity.id, charities.first.id
    assert_equal 70, charities.first.votes_count.to_i
    assert_equal 3, charities.first.causes_count.to_i
    assert_equal 300, charities.first.total_funds_raised.to_i
  end
=begin
  test "should mark as deleted and delete related causes" do
    charity = Charity.make :status => :active

    #causes status: inactive active raising_funds completed paid deleted
    inactive_cause_id  =  Cause.make(:status => :inactive, :charity_id => charity.id).id
    active_cause_id  = Cause.make(:status => :active, :charity_id => charity.id).id
    raising_funds_cause  = Cause.make :status => :raising_funds, :charity_id => charity.id
    completed_cause  = Cause.make :status => :completed, :charity_id => charity.id
    paid_cause  = Cause.make :status => :paid, :charity_id => charity.id
    deleted_cause  = Cause.make :status => :deleted, :charity_id => charity.id

    charity.destroy
    assert_equal :deleted, charity.reload.status, "Status of charity is not deleted"
    assert_equal :deleted, raising_funds_cause.reload.status, "Status of raising found cause is not deleted"
    assert_equal :deleted, completed_cause.reload.status, "Status of completed_cause is not deleted"
    assert_equal :deleted, paid_cause.reload.status, "Status of paid cause is not deleted"
    assert_equal :deleted, deleted_cause.reload.status, "Status of deleted cause is not deleted"

    assert_raise ActiveRecord::RecordNotFound do
      Cause.find_deleted(active_cause.id)
    end

    assert_raise ActiveRecord::RecordNotFound do
      Cause.find_deleted(inactive_cause.id)
    end

  end

  test "should delete from database and related causes" do
    charity = Charity.make :status => :active
    charity_id = charity.id
    #causes status: inactive active raising_funds completed paid deleted
    inactive_cause_id =  Cause.make(:status => :inactive, :charity_id => charity_id).id
    active_cause_id = Cause.make(:status => :active, :charity_id => charity_id).id

    charity.destroy

    assert_raise ActiveRecord::RecordNotFound do
      Cause.find_deleted(active_cause_id)
    end

    assert_raise ActiveRecord::RecordNotFound do
      Cause.find_deleted(inactive_cause_id)
    end

    assert_raise ActiveRecord::RecordNotFound do
      Charity.find_deleted(charity_id)
    end

  end


  test "should not retrieve deleted charities on default scope" do
    charities = Charity.make_many 2, :status => :active

    id1 = charities.first.id
    id2 = charities.last.id

    cause1 = Cause.make :status => :raising_funds,:charity_id => id1

    charities.first.destroy
    assert_equal 1, Charity.count, "Deleted charity is retrieved"
    assert_equal id2, Charity.first.id, "Charity id does not match"

    assert_not_nil Charity.find_deleted(id1), "Deleted charity is not retrieved with exclusive scope"
  end
=end
end

