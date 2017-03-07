require "rss"
require "open-uri"

class NewsParserJob < ActiveJob::Base

  def perform(souce_id)
    source = Source.find(souce_id)
    open(source.link) do |rss|
      feed = RSS::Parser.parse(rss)

      feed.items.each do |item|
        Post.create(description: item.description, link: item.link, published_at: item.pubDate,
          title: item.title, category_id: source.category_id, source: source)
      end
    end
  end
end
