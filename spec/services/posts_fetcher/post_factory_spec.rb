require "rails_helper"

RSpec.describe PostsFetcher::PostFactory do
  describe "#create" do
    subject { described_class.new(source: source, item: item).create }

    let(:source) { create(:source) }
    let(:valid_post_attributes) do
      attributes_for(:post).merge(image_url: "url").except(:stemmed_text, :state)
    end
    let(:item) { instance_double(PostsFetcher::FetchedItem, valid_post_attributes) }

    context "when passed item has valid params" do
      it "returns valid post" do
        is_expected.to be_a_kind_of(Post)
        is_expected.to be_valid
      end

      context "when source has category" do
        let(:category) { create(:category) }
        let(:source) { create(:source, category: category) }

        it "becomes a category of post" do
          expect(subject.categories).to match([category])
        end
      end

      context "when source doesn't have category" do
        let(:source) { create(:source, category: nil) }

        it "doesn't affect on post categories" do
          expect(subject.categories).to be_empty
        end
      end
    end

    context "when passed item has invalid params" do
      let(:existing_post) { create(:post) }
      let(:invalid_post_attributes) { valid_post_attributes.merge(link: existing_post.link) }
      let(:item) { instance_double(PostsFetcher::FetchedItem, invalid_post_attributes) }

      it "returns invalid post" do
        is_expected.to be_a_kind_of(Post)
        is_expected.not_to be_valid
      end
    end
  end
end
