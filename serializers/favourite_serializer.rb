class FavouriteSerializer < ActiveModel::Serializer
  attributes :id, :deleted_at
  # TODO: the question data is large to be added
  # in the favorite we may need a custom fields here
  has_one :question
end
