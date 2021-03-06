require "rails_helper"

describe Topic do
  describe "relations" do
    it { is_expected.to belong_to(:main_post).class_name("Post") }
    it { is_expected.to have_many(:posts).dependent(:destroy) }
  end

  describe "#sources_of_all_posts" do
    it "returns source of main post and other posts" do
      main_post = build(:post)
      posts = [build(:post), build(:post)]
      topic = build(:topic, main_post: main_post, posts: posts)

      expect(topic.sources_of_all_posts).to include(main_post.source)
      expect(topic.sources_of_all_posts).to include(posts[0].source)
      expect(topic.sources_of_all_posts).to include(posts[1].source)
    end
  end
end
