class PulStore::Lae::TopicsController < ApplicationController
  respond_to :json
  
  def index
    @topics = PulStore::Lae::Subject.find(params[:subject_id]).topics
  end

end
