class Api::V1::FavouritesController < BaseController
	before_action :load_question
	before_action :authenticate_with_token!
	
	##
	# Add to favourite
	# = params
		 # question_id
	# = return
		 # favourite json object
	# = URL
	#   POST  /questions/:question_id/favourites/
	#
	#
	# = Examples
    #
    #   resp = conn.post("/api/v1/questions/1/favourites/")
    #
    #   resp.status
    #   => 201
    #
    #   resp.body
    #   => [{"status":"true","favourite":{"id":2,"question_id":1,"deleted_at":null,"created_at":"2015-07-27T15:10:32.237Z","updated_at":"2015-07-27T15:10:32.237Z"}}]

	def create
		@favourite = Favourite.new(favourite_params)
		if @favourite.save
			render json: { status: true, favourite: @favourite}, status: :created
		else
			render json: { status: false, message: I18n.t('favourites.create.invalid'), errors: @favourite.errors}, status: :unprocessable_entity
		end
	end

	##
	# Remove favourite
	# = params
		 # question_id
	# = return
		 # favourite json object
	# = URL
	#   DELETE questions/:question_id/favourites
	#
	#
	# = Examples
    #
    #   resp = conn.delete("/api/v1/questions/1/favourites/")
    #
    #   resp.status
    #   => 204
    #
    #   resp.body
    #   => [{"status":"true","favourite":{"id":1,"question_id":1,"deleted_at":"2015-07-27T15:14:00.988Z","created_at":"2015-07-27T09:36:51.000Z","updated_at":"2015-07-27T09:36:51.000Z"}}]

	def destroy
		if @favourite = Favourite.where(question_id: params[:question_id]).first
	  	@favourite.destroy
	  	render json: { status: true, message: I18n.t('favourites.destroyed')}, status: :no_content
	  else
	  	render json: { status: false}, status: :unprocessable_entity
		end
	end

	private

	def favourite_params
		params[:user_id] = current_user.id
		params.permit(:user_id, :question_id)
	end

	def load_question
	  	@question = Question.where(id: params[:question_id]).first
	  	if !@question
	  		render json: {status: false, message: I18n.t('questions.not_found')}, status: :not_found
	  	end	
  	end 
end
