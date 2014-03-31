class RecordsController < ApplicationController
  include RecordsControllerBehavior

  def new
    @folder = PulStore::Lae::Folder.new
    render 'pul_store/lae/folders/new'
  end

  # You custom code
end
