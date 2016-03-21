class Favourite < ActiveRecord::Base
	
	#relations	
  belongs_to :question
  belongs_to :user

  #validations
  validates :user, presence: true
  validates :question, presence: true, uniqueness: { scope: :user_id }
end
