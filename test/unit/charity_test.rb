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

  test "should get not inactive nor deleted charities with cause data" do
    charity1 = Charity.make :status => :inactive

   charity2 = Charity.make :status => :deleted

   charity3 = Charity.make :status => :active
    [20,10,40].each do |votes|
      Cause.make_with_votes :votes_count => votes, :charity => charity3, :funds_raised => 100.0
    end

    charities = Charity.with_cause_data.all
    assert_not_nil charities
    assert_equal 1, charities.size
    assert_equal charity3.id, charities.first.id
    assert_equal 70, charities.first.votes_count.to_i
    assert_equal 3, charities.first.causes_count.to_i
    assert_equal 300, charities.first.total_funds_raised.to_i

  end

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
      Cause.find_deleted(active_cause_id)
    end

    assert_raise ActiveRecord::RecordNotFound do
      Cause.find_deleted(inactive_cause_id)
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

  test 'shouldnt show inactive causes in charity details if not owner nor admin' do
    user = PersonalUser.make
    charity = Charity.make
    Cause.make_many(5,:status => :inactive,:charity => charity)
    assert_equal 0,charity.causes_to_show(user).count
    Cause.make_many(5,:status => :active,:charity => charity)
    assert_equal 5,charity.causes_to_show(user).count
    c = Cause.make :status => :active,:charity => charity
    assert_equal c, charity.causes_to_show(user).last
  end

  test 'should show inactive causes in charity details if owner' do
    charity = Charity.make
    Cause.make_many(5,:status => :inactive,:charity => charity)
    assert_equal 5,charity.causes_to_show(charity).count
    Cause.make_many(5,:status => :active,:charity => charity)
    assert_equal 10,charity.causes_to_show(charity).count
    c = Cause.make :status => :active,:charity => charity
    assert_equal c, charity.causes_to_show(charity).last
  end

  test 'should show inactive causes in charity details if admin' do
    admin = Admin.make
    charity = Charity.make
    Cause.make_many(5,:status => :inactive,:charity => charity)
    assert_equal 5,charity.causes_to_show(admin).count
    Cause.make_many(5,:status => :active,:charity => charity)
    assert_equal 10,charity.causes_to_show(admin).count
    c = Cause.make :status => :active,:charity => charity
    assert_equal c, charity.causes_to_show(admin).last
  end
  
  test 'should not save charity with invalid rating' do
    charity = Charity.make
    charity.rating = -1
    assert !charity.save
    charity.rating = 6
    assert !charity.save
    charity.rating = 5
    assert  charity.save
    charity.rating = 0
    assert  charity.save
  end

  test 'should save charity with no rating' do
    charity = Charity.make
    charity.rating = nil
    assert charity.save
  end


end

