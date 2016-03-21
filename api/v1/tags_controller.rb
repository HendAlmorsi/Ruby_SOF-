class Api::V1::TagsController < BaseController

  before_action :authenticate_with_token!, except: [:index, :show]
  before_filter :load_tag, only: :update

  ##
  # Create tag
  # = params
     # question_id, tag name, description
  # = return
     # tag json object
     # <br><br>It check if the tag exists by searching for it ignoring the case
  # = URL
  #   POST  /tags/
  #
  #
  # = Examples
  #   
  #   resp = conn.post("/api/v1/tags/?tag[name]=Json")
  #
  #   resp.status
  #   => 201
  #
  #   resp.body
  #   => ["status":"true","tag":{"id":12,"name":"Json","description":null,
  #       "created_at":"2015-07-29T09:58:21.034Z","updated_at":"2015-07-29T09:58:21.034Z"}]
  def create

    @tag = Tag.new(tag_params)

    	if @tag.save
    		render json: {status: true, tag: @tag}, status: :created
      else
        render json: {status: false, error: @tag.errors}, status: :unprocessable_entity
      end
  end

  ##
  # Update tag
  # = params
     # question_id, tag name, tag description
  # = return
  # = URL
  #   PUT  /api/v1/tags/:id
  #
  #
  # = Examples
  #   
  #   resp = conn.put("/api/v1/tags/9/?tag[name]=Html&auth_token=XxcFzXr_dzX1XWZoksqt")
  #
  #   resp.status
  #   => 200
  #
  #   resp.body
  #   => [{"status":"true","tag":{"id":9,"name":"Js","description":"Edit",
  #       "created_at":"2015-07-28T12:47:11.000Z","updated_at":"2015-08-04T14:20:19.683Z"}}]
  def update   
    if @tag.update_attributes(tag_params)
      render json: {status: true, tag: @tag}, status: :ok
    else
      render json: {status: false, error: I18n.t('tags.invalid')}, status: :unprocessable_entity
    end
  end

  ##
  # Search/list tags
  # = params
    # query, filter
  # = return
    # tag paginated json object
  # = availabe filters
    # (newest,popular,name)   
  # = URL
  #   GET  /tags
  #
  #
  # = Examples
  #   
  #   resp = conn.get("/api/v1/tags?&page=1")
  #
  #   resp.status
  #   => 200
  #
  #   resp.body
  #   => ["status":"true","tag":{"id":9,"name":"JS","description":null,
  #       "created_at":"2015-07-28T12:47:11.000Z","updated_at":"2015-07-29T10:38:41.259Z"}]

  def index
     @tags = Tag.search(params[:query], params[:filter])
     paginate json: @tags, status: :ok
  end

  def show
  	@tag = Tag.find(params[:id])
    render json: @tag
  end


  private

  def tag_params
    params.require(:tag).permit(:name, :description)
  end

  def load_tag
    @tag = Tag.where(id: params[:id]).first
    if !@tag
      render json: {status: false, error: I18n.t('tags.not_found')}, status: :not_found
    end
  end

end
