class Topics::Flag::NotReviewed::Cell < Topics::Flag::Cell
  private

  def reviewed_by_user_class
    "topic-flag--unflagged"
  end

  def button
    button_to(topic_reviews_path(topic), button_options) do
      yield
    end
  end

  def button_options
    super.merge({ method: :post, params: { flag_id: flag.id } })
  end
end