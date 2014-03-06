
class PulStore::Lae::BoxesController < CatalogController #ApplicationController
  include PulStore::Lae::BarcodeLookups
  include Hydra::Controller::ControllerBehavior

  layout 'lae'

  # include Blacklight::Catalog
  # include Blacklight::Configurable

  # enforce access controls
  # before_filter :enforce_show_permissions, only: [:show]

  before_action :set_box, only: [:show, :edit, :update, :destroy]
  before_filter :list_all_boxes, only: [:show]

  # This applies appropriate access controls to all solr queries
  PulStore::Lae::BoxesController.solr_search_params_logic += [:add_access_controls_to_solr_params]

  # This filters out objects that you want to exclude from search results, like FileAssets
  PulStore::Lae::BoxesController.solr_search_params_logic += [:exclude_unwanted_models]

  # Keep out everything but Boxes, only show state
  PulStore::Lae::BoxesController.solr_search_params_logic += [:limit_to_boxes]
  PulStore::Lae::BoxesController.solr_search_params_logic += [:sort_by_newest_first]

  # Note sure this is correct...global to be app?
  self.blacklight_config.add_sort_field 'prov_metadata__date_uploaded_ssi desc', :label => 'Date Created'
  self.blacklight_config.add_sort_field 'prov_metadata__shipped_date_ssi desc', :label => 'Date Shipped'
  self.blacklight_config.add_sort_field 'prov_metadata__received_date_ssi desc', :label => 'Date Received'


  #load_and_authorize_resource

  def limit_to_boxes(solr_parameters, user_params)
      fq = '{!raw f=active_fedora_model_ssi}PulStore::Lae::Box'
      solr_parameters[:fq] << fq
      # solr_parameters.append_filter_query << fq # BL 5
      solr_parameters[:"facet.field"] = ["prov_metadata__workflow_state_sim"]
  end

  def sort_by_newest_first(solr_parameters, user_params)
    solr_parameters[:sort] = 'prov_metadata__date_uploaded_ssi desc'
  end

  def index
    if params[:barcode]
      # this is slow...what's a better (Solr-only?) way?
      @box = get_box_by_barcode(params[:barcode])

      if @box
        redirect_to(@box)
      else
        redirect_to :back, notice: "No Box with barcode \"#{params[:barcode]}\" found."
      end
    else
      (@response, @document_list) = get_search_results
      @filters = params[:f] || []
      respond_to do |format|
        format.html
      end
    end
  end

  def show
    authorize! :show, params[:id]
    @box = PulStore::Lae::Box.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @box }
    end
  end

  def new
   @box = PulStore::Lae::Box.new
   1.times { @box.folders.build}
   ## Assign to the first Project
   #FIXME Project assigne shoudl come from the content of the Object in PulStore Hierarchy
  end

  def edit
    authorize! :edit, params[:id]
    @box = PulStore::Lae::Box.find(params[:id])

    if(@box.folders.size < 1)
      1.times { @box.folders.build}
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @box }
    end
  end

  # POST
  def create
    @box = PulStore::Lae::Box.new(box_params)
    project = PulStore::Project.first
    @box.project = project
    respond_to do |format|
      if @box.save
        format.html { redirect_to @box, notice: 'Box was successfully created.' }
        format.json { render action: 'show', status: :created, location: @box }
      else
        format.html { render action: 'new' }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT
  def update
    authorize! :update, params[:id]
    respond_to do |format|
      if @box.update(box_params.except('project_pid'))
        format.html { redirect_to @box, notice: 'Box was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE
  def destroy
    authorize! :destroy, params[:id]
    respond_to do |format|
      if @box.destroy
        format.html { redirect_to lae_boxes_path, notice: 'Box was successfully deleted.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_box
      @box = PulStore::Lae::Box.find(params[:id])
    end

    def list_all_boxes
      @boxes = PulStore::Lae::Box.all
    end
    # Never trust parameters from the scary internet, only allow the
    # white list through.

    #FIXME confirm that these are the correct params
    def box_params
      params.require(:lae_box).permit(:full, :barcode, :error_note,
        :physical_location, :tracking_number, :shipped_date, :received_date,
        :project, :id, :project, folders_attributes: [:genre, :page_count,
        :width_in_cm, :height_in_cm, :barcode, :folder_id, :_destroy] )

    end
end
