class PulStore::Lae::SubjectsController < ApplicationController
  def index
    if request.format == 'json'
      @subjects = PulStore::Lae::Category.find(params[:category_id]).subjects
    else
      # This will still cause problems if a request comes in for subjects.format 
      # e.g. (subjects.html)
      redirect_to "#{request.original_url}.json", status: :moved_permanently
    end
  end
end
