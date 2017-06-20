class Posts::Approved::Item::Cell < Posts::PostItem::Cell
  IMAGE_NAME = { "upvote" => "fi-like", "downvote" => "fi-dislike" }.freeze
  BUTTON_STYLE = { "upvote" => "success", "downvote" => "alert" }.freeze
  UPVOTE = "upvote".freeze
  VOTE_ACCORDION_OPEN = "info_button".freeze

  option :user_votes
  property :votes

  private

  def tooltip_wraper(button)
    unless user
      tolltip_title = t("user.should_login")
      tooltip = "<span data-tooltip aria-haspopup='true' data-tooltip='' class='has-tip top' title='#{tolltip_title}'>"
      button = tooltip + button + "</span>"
    end
    button
  end

  def user_vote
    user_votes.detect { |vote| vote.post_id == id }
  end

  def vote_button(type)
    if user.nil?
      tooltip_wraper("<a class='secondary'>#{button_text(type)}</a>")
    else
      link_to nil, class: "js-#{type}-button",
        data: { type: type, path: votes_path(type: type, post_id: id) } do
        button_text(type)
      end
    end
  end

  def button_text(type)
    "<i class=#{IMAGE_NAME[type]}></i>"
  end

  def vote_count
    vote_array = votes.map(&:positive)
    vote_array.count(true) - vote_array.count(false)
  end

  def button_style
    if user_vote.present? && user_vote.try(:positive)
      "upvoted"
    elsif user_vote.present? && !user_vote.try(:positive)
      "downvoted"
    end
  end
end
