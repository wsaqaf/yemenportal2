# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  description      :text
#  published_at     :datetime
#  link             :string           not null
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  state            :string           default("pending"), not null
#  image_url        :string
#  topic_id         :integer
#  stemmed_text     :text             default("")
#  source_id        :integer          not null
#  voting_result    :integer          default("0")
#  post_views_count :integer          default("0"), not null
#  review_rating    :integer          default("0"), not null
#
# Indexes
#
#  index_posts_on_link           (link)
#  index_posts_on_published_at   (published_at)
#  index_posts_on_source_id      (source_id)
#  index_posts_on_topic_id       (topic_id)
#  index_posts_on_voting_result  (voting_result)
#

class Post < ApplicationRecord
  extend Enumerize

  has_many :post_category
  has_many :categories, through: :post_category
  has_many :reviews, dependent: :destroy
  has_many :review_comments, -> { ordered_by_date }, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :related_posts, through: :main_topic, source: :posts
  has_many :post_views, dependent: :destroy

  belongs_to :source
  belongs_to :topic, optional: true, counter_cache: :topic_size, touch: true

  has_one :main_topic, class_name: "Topic", foreign_key: :main_post_id, dependent: :destroy

  validates :published_at, :link, presence: true
  validates :link, uniqueness: true

  scope :ordered_by_date, -> { order("published_at DESC") }
  scope :ordered_by_voting_result, -> { order("voting_result DESC") }
  scope :ordered_by_views_count, -> { order(post_views_count: :desc) }
  scope :order_by_review_rating, -> { order(review_rating: :desc) }
  scope :ordered_by_coverage, lambda {
    left_joins(:main_topic)
      .group(:id)
      .select('"posts".*, SUM("topics"."topic_size") AS "topic_size"')
      .order('"topic_size" DESC NULLS LAST')
  }
  scope :source_posts, ->(source_id) { ordered_by_date.where(source_id: source_id) }
  scope :pending_posts, -> { where(state: :pending).ordered_by_date }
  scope :approved_posts, -> { where(state: :approved).ordered_by_date }
  scope :rejected_posts, -> { where(state: :rejected).ordered_by_date }
  scope :not_for_source, ->(source_id) { where.not(source_id: source_id) }
  scope :created_after_date, ->(date) { where("created_at > ?", date) }
  scope :posts_by_state, ->(state) { where(state: state).order("published_at DESC") }
  scope :for_search_query, lambda { |query|
    where('concat_ws(\' \', "posts"."title", "posts"."description") LIKE ?', "%#{sanitize_sql_like(query)}%")
  }
  scope :with_user_votes, lambda { |user|
    joins("LEFT JOIN votes ON votes.post_id = posts.id AND votes.user_id = #{user.id}")
      .group(:id).select("posts.*,
        (COUNT(votes.*) > 0 AND SUM(votes.value) > 0) AS upvoted_by_user,
        (COUNT(votes.*) > 0 AND SUM(votes.value) < 0) AS downvoted_by_user")
  }
  scope :for_categories, lambda { |categories|
    joins(:post_category)
      .where(post_categories: { category: Array(categories) })
      .distinct
  }
  scope :non_clustered_posts, lambda {
    Post
      .joins('LEFT JOIN "topics" ON "topics"."main_post_id" = "posts"."id"')
      .where(topics: { main_post_id: nil })
      .where(topic: nil)
  }

  enumerize :state, in: [:approved, :rejected, :pending], default: :pending

  def self.include_voted_by_user(user)
    if user.present?
      with_user_votes(user)
    else
      all
    end
  end

  def self.published_later_than(timestamp)
    where("posts.published_at > ?", timestamp)
  end

  def self.available_states
    state.values
  end

  def self.include_review_comments
    includes(review_comments: [:author])
  end

  def main_post_of_topic?
    main_topic.present?
  end

  def related_post_of_topic?
    topic.present?
  end

  def same_posts
    (topic.posts.ordered_by_date - [self]) if topic
  end

  def source_name
    source.name
  end

  def category_names
    if categories.present?
      categories.map(&:name)
    else
      []
    end
  end

  def show_internally?
    source.show_internally?
  end

  def update_voting_result(new_value)
    update(voting_result: new_value)
  end

  def upvoted_by_user?
    attributes["upvoted_by_user"] || false
  end

  def downvoted_by_user?
    attributes["downvoted_by_user"] || false
  end
end
