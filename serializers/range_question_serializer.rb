class RangeQuestionSerializer < ActiveModel::Serializer
  attributes :id, :max, :min
  has_one :question
end
