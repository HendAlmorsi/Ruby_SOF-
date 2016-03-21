class MultipleChoice < ActiveRecord::Base
  belongs_to :question
  # TODO: leave space after :response_number
  validates :question_id, uniqueness: { scope: :response_number}
  validates :response_text, :response_number, presence: true

  #functions
  def is_valid(answer,checks)
  	checks.each do |check|
  		if check.response_text == answer
  			return true
  		end
  	end
  	return false
  end

end
