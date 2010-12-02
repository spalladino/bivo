require 'test_helper'

class CauseTest < ActiveSupport::TestCase

  test "should create voted cause" do
    cause = Cause.make_with_votes :votes_count => 5
    assert_equal 5, cause.votes.count
  end

  test "should increase vote counter" do
    cause = Cause.make :status => :active
    assert_equal 0, cause.votes_count

    cause.votes.make
    cause.reload
    assert_equal 1, cause.votes_count
  end

  test "should mark as deleted" do
    cause = Cause.make :status => :raising_funds
    cause.destroy
    assert_equal :deleted, cause.reload.status, "Status is not deleted"
  end

  test "should delete from database" do
    cause = Cause.make :status => :active
    id = cause.id
    cause.destroy

    assert_raise ActiveRecord::RecordNotFound do
      Cause.find_deleted(id)
    end
  end

  test "should not retrieve deleted causes on default scope" do
    causes = Cause.make_many 2, :status => :raising_funds
    id1 = causes.first.id
    id2 = causes.last.id

    causes.first.destroy
    assert_equal 1, Cause.count, "Deleted cause is retrieved"
    assert_equal id2, Cause.first.id, "Cause id does not match"

    assert_not_nil Cause.find_deleted(id1), "Deleted cause is not retrieved with exclusive scope"
  end

  test "should change status from active to raising founds" do
    cause = Cause.make :status => :active
    cause.status = :raising_funds
    cause.save

    assert_equal Cause.find(cause.id).status, :raising_funds
  end

  test "shouldnt change status from active to completed" do
    cause = Cause.make :status => :active
    cause.status = :completed
    cause.save

    assert_not_equal Cause.find(cause.id).status, :completed
  end

  test "should change status from inactive to active" do
    cause = Cause.make :status => :inactive
    cause.status = :active
    cause.save

    assert_equal Cause.find(cause.id).status, :active
  end

  test "shouldnt change status from inactive to raising_funds" do
    cause = Cause.make :status => :inactive
    cause.status = :raising_funds
    cause.save

    assert_not_equal Cause.find(cause.id).status, :raising_funds
  end

  test "should change status to completed if all funds were raised" do
    cause = Cause.make :status => :raising_funds, :funds_needed => 100, :funds_raised => 0
    assert_equal :raising_funds, cause.status
    cause.funds_raised += 50
    cause.save!
    assert_equal :raising_funds, cause.status

    cause.funds_raised += 50
    cause.save!
    assert_equal :completed, cause.status
  end

  test "should get the most voted cause (the oldest one from them if there is more than one)" do
    cause_category = CauseCategory.make
    Cause.make_many 5, :cause_category => cause_category
    causes = Cause.order("created_at")
    Vote.make_many 5, :cause => causes[1]
    Vote.make_many 3, :cause => causes[2]
    Vote.make_many 5, :cause => causes[3]

    assert_equal causes[1], Cause.most_voted_cause(cause_category)
  end

  test "should get the most voted cause in date range" do
    cause_category = CauseCategory.make
    cause = Cause.make :cause_category => cause_category
    Vote.make_many 3, :created_at => 1.month.ago, :cause => cause

    assert_not_nil Cause.most_voted_cause(cause_category, 1.month.ago - 1.day, 1.month.ago + 1.day)
    assert_nil Cause.most_voted_cause(cause_category, 1.month.ago + 1.day, Date.today)
    assert_nil Cause.most_voted_cause(cause_category, 1.year.ago, 1.month.ago - 1.day)
  end

  test "should get the most voted cause for each category" do
    cause_categories = CauseCategory.all
    causes = []
    cause_categories.each { |cat| causes += Cause.make_many(5, :cause_category => cat) }
    causes.each { |c| Vote.make_many(3, :cause => c) }

    assert_equal Set.new(CauseCategory.all), Set.new(Cause.most_voted_causes.map(&:cause_category))
  end
end

