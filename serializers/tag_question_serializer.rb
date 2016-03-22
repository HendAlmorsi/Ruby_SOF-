class TagQuestionSerializer < ActiveModel::Serializer
  attributes :id
  has_one :tag
  has_one :question
end
