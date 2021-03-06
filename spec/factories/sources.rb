# == Schema Information
#
# Table name: sources
#
#  id            :integer          not null, primary key
#  link          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  category_id   :integer
#  state         :string           default("valid")
#  name          :string           default(""), not null
#  website       :string
#  brief_info    :string
#  admin_email   :string
#  admin_name    :string
#  note          :string
#  source_type   :string
#  approve_state :string           default("suggested")
#  user_id       :integer
#  iframe_flag   :boolean          default("true")
#  logo_url      :string
#  deleted_at    :datetime
#
# Indexes
#
#  index_sources_on_category_id  (category_id)
#  index_sources_on_user_id      (user_id)
#

FactoryGirl.define do
  factory :source do
    sequence(:link) { |n| "http://source_#{n}@gar.com" }
    association :category
    sequence(:name) { |n| "name_#{n}" }
    sequence(:website) { |n| "http://source_#{n}.ru" }
    iframe_flag true
  end
end
