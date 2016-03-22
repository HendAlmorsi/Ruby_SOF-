class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :status, :num_views, :question_type
  has_many :tags
  has_many :multiple_choices
  has_many :range_questions
  url :question
end
