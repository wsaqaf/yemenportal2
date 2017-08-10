# == Schema Information
#
# Table name: votes
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  topic_id   :integer          not null
#  value      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_votes_on_topic_id  (topic_id)
#  index_votes_on_user_id   (user_id)
#

FactoryGirl.define do
  factory :vote do
    association :user
    association :post
    positive false
  end
end
