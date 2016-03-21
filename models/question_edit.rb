class QuestionEdit < ActiveRecord::Base
  belongs_to :question
  belongs_to :user

	after_create :set_approve?

	#Validation
	validates  :user, :body, presence: true
  
  # TODO: leave space after the first ( 
  # TODO: if statement is too long try breaking it or adding the condition into 
  # variable which will make it more readable
	def set_approve?(approve_param = nil)
			if((user_id === question.user_id && approve_param === nil) || (approve_param === "true"))
				self.approve = true
				true
			elsif(approve_param === "false")
				false
			else
				self.approve = false
			end		
	end
end
