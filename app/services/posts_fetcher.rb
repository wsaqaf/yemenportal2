class PostsFetcher
  def initialize(source)
    @source = source
  end

  def fetch!
    fetched_items.each do |item|
      PostsFetcher::ItemSaver.new(source: source, item: item).save!
    end
  end

  private

  attr_reader :source

  def fetched_items
    fetcher.fetched_items
  end

  def fetcher
    Fetcher.for(source)
  end
end
