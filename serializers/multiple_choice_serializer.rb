class MultipleChoiceSerializer < ActiveModel::Serializer
  attributes :id, :response_text, :response_number
  has_one :question
end
