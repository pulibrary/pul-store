class PulStore::Lae::BoxesController < ApplicationController
  include Hydra::Controller::ControllerBehavior
  include PulStore::Lae::BarcodeLookups
  # enforce access controls

  before_action :set_box, only: [:show, :edit, :update, :destroy]
  before_filter :list_all_boxes, only: [:show]

  #load_and_authorize_resource

  def index
    if params[:barcode]
      @box = get_box_by_barcode(params[:barcode])

      if @box
        redirect_to(@box)
      else
        redirect_to :back, notice: "No Box with barcode \"#{params[:barcode]}\" found."
      end
    else
         #authorize! :edit, params[:id]
        @boxes = PulStore::Lae::Box.all
    end
  end

  # GET /lae/boxes/1
  # GET /lae/boxes/1.json
  def show
    authorize! :show, params[:id]
    @box = PulStore::Lae::Box.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @box }
    end
  end

  # GET /lae/boxes/new
  def new
   @box = PulStore::Lae::Box.new
   ## Assign to the first Project
   #FIXME Project assigne shoudl come from the content of the Object in PulStore Hierarchy
  end

  # # GET /lae/boxes/1/edit
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

  # POST /lae/boxes
  # POST /lae/boxes.json
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

  # PATCH/PUT /lae/boxes/1
  # PATCH/PUT /lae/boxes/1.json
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

  # DELETE /lae/boxes/1
  # DELETE /lae/boxes/1.json
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
        :project, :id, :project, folders_attributes: [:genre, :page_count, :width_in_cm, :height_in_cm, :barcode, :id, :_destoy, :_new] )

    end
end
