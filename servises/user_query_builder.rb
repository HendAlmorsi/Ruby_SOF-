class UserQueryBuilder

  $valid_options = ["newest", "Newest", "question", "Question",
                 "answer", "Answer", "Vote", "vote", "Comment", "comment","Favourite","favourite"]
  $valid_filters = ["question", "Question", "answer", "Answer", "Vote",
                 "vote", "Comment", "comment"]


  def initialize(params, user)
    @params = params
    @user = user
  end
  
  # TODO: method name is not camelcased i.e. get_query
  def getQuery
    if !@params[:option].nil?
      @params[:option].capitalize!
      if @params[:filter].nil?
        @output = build_query_with_user_id
      else
        @params[:filter].capitalize!
        @output = build_query_with_more_params
      end
      return @output = add_includes(@output)
    else
      return @user
    end
  end

  # TODO: try make the if condition easier to read by 
  # adding the boolean condition value inside a variable 
  def validate_input
    is_valid_option = false
    $valid_options.each { |option|
      if !@params[:option] || @params[:option] == option
        is_valid_option = true
      end
    }
    is_valid_filter = true
    if @params[:option] == 'newest' || @params[:option] == "vote"
      is_valid_filter = false
      $valid_filters.each { |filter|
        if !@params[:filter].nil? && @params[:filter] == filter
          is_valid_filter = true
        end
      }
    end
    is_valid_filter & is_valid_option
  end


  private

  def build_query_with_user_id
    @params[:option].constantize.where(user_id: @params[:id])
  end

  def build_query_with_user_id_for_newest
    @params[:filter].constantize.where(user_id: @params[:id])
  end


  def build_query_with_more_params
    if @params[:option] == "Votes"
      @params[:option].constantize.where(user_id: @params[:id],
                                       votable_type: @params[:filter])
    elsif @params[:option] == "Newest"
      build_query_with_user_id_for_newest.order('created_at desc')
    end
  end

  def add_includes (output)
    if @params[:option] == "Answer" || @params[:filter] == "Answer" || @params[:filter] == "favourite"
      output = output.includes(:question)
    elsif @params[:option] == "Comment" || @params[:filter] == "Comment"
      output = output.includes(:commentable)
    end
    return output
  end

end
