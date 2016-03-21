class RangeQuestion < ActiveRecord::Base
  belongs_to :question

  validates :min, :max, presence: true

  #functions

  def is_valid(answer,check)
  	@answer = answer.to_f
  	@check = check.first
  	return @answer >= @check.min && @answer <= @check.max
  end
end
