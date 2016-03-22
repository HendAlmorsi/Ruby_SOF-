class QuestionQueryBuilder

  # TODO: its a sort of waste for having uppercase and lowercase combinations
  # you have doubled the is_valid_param time
  # All valid filters and sorts
  $valid_filters = ["newest", "active", "featured", "with_type", "unanswered", "vote"]
  $valid_sort = ["noanswers", "vote", "newest"]

  # Contractor
  def initialize(params)
    @params = params
  end

  # Use this method to get the required query
  def getQuery
    # Question.search(@params[:filter], @params[:tag], @params[:sort])
    search(@params[:filter], @params[:type], @params[:tag], @params[:sort])
  end

  # Validates the input parameters
  def validate_input
    is_valid_param(@params[:filter], $valid_filters) &
        is_valid_param(@params[:sort], $valid_sort)
  end


  private


  def search(filter, type = nil, tag = nil, sort = nil)
    query = Question.all
    if filter
      if filter == "with_type"
        if type
          query = Question.with_type(type)
        else
          query = Question.with_type_not_default
        end
      else
        query = Question.send(filter.downcase.to_sym)
      end

      if sort && filter === "unanswered"
        query = Question.send(sort.downcase.to_sym)
      end
    end
    if tag
      query = query.tag_filter(tag)
    else
      query
    end
  end

  # TODO: instead of using is_valid param we can simply
  # return param.nil?
  def is_valid_param (param, valid_array)
    is_valid = false
    if param.nil?
      is_valid = true
    else
      param.downcase!
      valid_array.each { |item|
        if param == item
          is_valid = true
        end
      }
    end
    is_valid
  end

end
