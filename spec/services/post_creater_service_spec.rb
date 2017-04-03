require "rails_helper"

describe PostCreaterService do
  let(:source) { create(:source) }

  describe "#add_post" do
    let(:item) { double(description: "description", link: "link", pubDate: Time.new, title: "title") }

    context "source has category", slow: true do
      before do
        described_class.add_post(item, source)
      end

      it "post created with item fields" do
        post = Post.find_by(published_at: item.pubDate)
        expect(post.attributes).to include("description" => item.description, "link" => item.link,
          "source_id" => source.id, "title" => item.title)
      end

      it "post has category" do
        post = Post.find_by(published_at: item.pubDate)
        expect(post.categories).to include(source.category)
      end
    end

    context "source hasn't category", slow: true do
      it "post hasn't category too" do
        allow(source).to receive(:category).and_return(nil)

        described_class.add_post(item, source)

        post = Post.find_by(published_at: item.pubDate)
        expect(post.categories.to_a).to eql([])
      end
    end

    describe "(module tests)" do
      let(:post) { build :post }
      let(:whitelisted_source) { create(:source, whitelisted: true) }

      it "post call save action" do
        allow(Post).to receive(:new).with(description: "description", link: "link", published_at: item.pubDate,
          title: item.title, source: source).and_return(post)
        allow(post).to receive(:categories=).with([source.category]).and_return(post)

        expect(post).to receive(:save)

        described_class.add_post(item, source)
      end

      it "post with approve state" do
        allow(Post).to receive(:new).with(description: "description", link: "link", published_at: item.pubDate,
          title: item.title, source: whitelisted_source).and_return(post)

        described_class.add_post(item, whitelisted_source)
        expect(post.state).to eql("approved")
      end

      it "not set category" do
        allow(Post).to receive(:new).with(description: "description", link: "link", published_at: item.pubDate,
          title: item.title, source: source).and_return(post)
        allow(source).to receive(:category).and_return(nil)
        expect(post).not_to receive(:categories=)

        described_class.add_post(item, source)
      end

      %i(link pubDate title).each do |field|
        it "rais error when #{field} is empty" do
          allow(item).to receive(field).and_return(nil)

          expect(source).to receive(:update).with(state: Source.state.not_full_info)
          described_class.add_post(item, source)
        end
      end
    end
  end
end
