class PulStore::Lae::FoldersController < CatalogController
  include PulStore::Lae::PageLookups
  include PulStore::Lae::BoxLookups

  before_action :set_folder, only: [:show, :edit, :update, :destroy]
  before_action :redirect_to_sign_in, unless: :user_signed_in?, only: [:edit, :update, :destroy, :create]
  #before_action :authenticate_user!
  

  layout 'lae'

  # This applies appropriate access controls to all solr queries
  PulStore::Lae::FoldersController.solr_search_params_logic += [:add_access_controls_to_solr_params]

  # This filters out objects that you want to exclude from search results, like FileAssets
  #PulStore::Lae::FoldersController.solr_search_params_logic += [:exclude_unwanted_models]

  # Keep out everything but Boxes, only show state
  PulStore::Lae::FoldersController.solr_search_params_logic += [:limit_to_folders]
  PulStore::Lae::FoldersController.solr_search_params_logic += [:set_facets]
  PulStore::Lae::FoldersController.solr_search_params_logic += [:sort_by_newest_first]

  # Note sure this is correct...global to be app?
  self.blacklight_config.add_sort_field 'prov_metadata__date_uploaded_ssi desc', :label => 'Date Created'
  self.blacklight_config.add_sort_field 'prov_metadata__shipped_date_ssi desc', :label => 'Date Shipped'
  self.blacklight_config.add_sort_field 'prov_metadata__received_date_ssi desc', :label => 'Date Received'

  def limit_to_folders(solr_parameters, user_params)
      fq = '{!raw f=active_fedora_model_ssi}PulStore::Lae::Folder'
      solr_parameters[:fq] << fq
  end

  def set_facets(solr_parameters, user_params)
      solr_parameters[:"facet.field"] = [
        "prov_metadata__workflow_state_sim",
        "desc_metadata__genre_sim",
        "desc_metadata__language_sim",
        "desc_metadata__geographic_subject_sim",
        "desc_metadata__category_sim",
        "desc_metadata__subject_sim",
        'in_box_sim'
        # TODO: category, subject
      ]
  end

  def sort_by_newest_first(solr_parameters, user_params)
    solr_parameters[:sort] = 'prov_metadata__date_uploaded_ssi desc'
  end

  def index
    #authorize! :index, params[:id]
    session[:path_to_redirect_to] = request.original_fullpath
    if params[:barcode]
      @folder = set_folder_by_barcode
      @page_title = "Lae Folders"
      if @folder
        redirect_to(@folder)
      else
        redirect_to :back, notice: "No Folder with barcode \"#{params[:barcode]}\" found."
      end
    else
      (@response, @document_list) = get_search_results
      @filters = params[:f] || []
      respond_to do |format|
        format.html { render template: 'shared/lae/index' }
        format.json { render json: @document_list }
      end
    end
  end

  # GET /lae/folders/1
  # GET /lae/folders/1.json
  def show
    authorize! :show, params[:id]
    @folder = PulStore::Lae::Folder.find(params[:id])
    @page_title = "Folder #{@folder.physical_number}"
    @pages_list = get_pages_by_folder @folder.id
    @box_list = get_box_by_id @folder.box_id
    
    respond_to do |format|
      format.html { setup_next_and_previous_documents } # show.html.erb
      format.json { render json: @folder }
      format.yml { render text: @folder.to_yaml(prod_only: !params.include?(:all)) }
      format.ttl { render text: @folder.to_ttl(prod_only: !params.include?(:all)) }
      format.xml { render xml: @folder.to_solr_xml(prod_only: !params.include?(:all)) }
    end
  rescue NoMethodError
    not_allowed
  end

  # displays an oversize osd modeal
  def image_list
    @folder = PulStore::Lae::Folder.find(params[:id])
    @page_title = "Folder #{@folder.physical_number}"
    @pages_list = get_pages_by_folder @folder.id
    respond_to do |format|
      format.html
    end
  end

  # GET /lae/folders/new
  def new
   #authorize! :create, PulStore::Lae::Folder
   @folder = PulStore::Lae::Folder.new
   @page_title = "Create a New Folder"
   render 'new'
  end

  # # GET /lae/folders/1/edit
  def edit
    authorize! :edit, params[:id]
    @folder = PulStore::Lae::Folder.find(params[:id])
    @page_title = "Edit Lae Folder #{@folder.physical_number}"
    @pages_list = get_pages_by_folder @folder.id
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @folder }
    end
    #initialize_fields
    #render 'records/edit'
  end

  # POST /lae/folders
  # POST /lae/folders.json
  def create
    #authorize! :create, PulStore::Lae::Folder
    @folder = PulStore::Lae::Folder.new(folder_params)
    #authorize! :create, @folder
    project = PulStore::Project.first
    @folder.project = project
    respond_to do |format|
      if @folder.save
        format.html { redirect_to @folder, notice: 'Folder was successfully created.' }
        format.js   { render action: 'create', notice: 'Folder was successfully created.' }
        format.json { render action: 'show', notice: 'Folder was successfully created.', status: :created, location: @folder }
      else
        format.html { render action: 'new' }
        format.js { render action: 'create', notice: 'Unable to save Folder.' }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lae/folders/1
  # PATCH/PUT /lae/folders/1.json
  def update
    authorize! :update, params[:id]
    respond_to do |format|
      if @folder.update(folder_params.except('project_pid'))
        format.html { redirect_to @folder, notice: 'Folder was successfully updated.' }
        format.json { head :no_content }
      else
        # repopulate these values for the response
        @page_title = "Edit Lae Folder #{@folder.physical_number}"
        @pages_list = get_pages_by_folder @folder.id
        format.html { render action: 'edit' }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lae/folders/1
  # DELETE /lae/folders/1.json
  def destroy
    authorize! :destory, params[:id]
    respond_to do |format|
      if @folder.destroy
        format.html { redirect_to lae_folders_path, notice: 'Folder was successfully deleted.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder
      @folder = PulStore::Lae::Folder.find(params[:id])
    end

    def set_folder_by_barcode
      PulStore::Lae::Folder.where(prov_metadata__barcode_tesi: params[:barcode]).first
    end

    def folder_params
      params.require(:lae_folder).permit(:barcode, :date_created, :earliest_created, :latest_created,
        :description, :width_in_cm, :height_in_cm, :page_count, :genre, :passed_qc, :rights, :physical_number,
        :sort_title, :suppressed,:box_id, :project_id, :error_note, :geographic_origin, :suppressed,
        :box_id, :all, alternative_title: [], geographic_subject: [], title: [], category: [],
        language: [], publisher: [], series: [], subject: [], creator: [], contributor: [])
    end

    def not_allowed
      render plain: 'By default this format is not available until the it is ready for production. Include ?all if you want to see it.', status: 406
    end

end
