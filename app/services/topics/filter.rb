class Topics::Filter
  def initialize(params)
    @params = Params.new(params)
  end

  def topics
    filters.reduce(all_topics) do |topics, filter|
      filter.call(topics)
    end
  end

  private

  attr_reader :params

  def all_topics
    ::Topic.all
  end

  def filters
    [
      page_filter,
      time_filter,
      sorting_filter
    ]
  end

  def page_filter
    ->(topics) { topics.paginate(page: params.page) }
  end

  def time_filter
    if params.all_time?
      ->(topics) { topics }
    else
      ->(topics) { topics.where("created_at > ?", beginning_time_from_params) }
    end
  end

  def beginning_time_from_params
    case params.time.to_sym
    when :daily
      1.day.ago
    when :weekly
      7.days.ago
    when :monthly
      1.month.ago
    end
  end

  def sorting_filter
    case params.set.to_sym
    when :new
      ->(topics) { topics.ordered_by_date }
    when :highly_voted
      ->(topics) { topics.ordered_by_voting_result.ordered_by_date }
    when :most_covered
      ->(topics) { topics.ordered_by_size.ordered_by_voting_result.ordered_by_date }
    end
  end
end
