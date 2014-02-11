class PulStore::Lae::FoldersController < ApplicationController
  before_action :set_folder, only: [:show, :edit, :update, :destroy]

  def index
    if params[:barcode]
      @folder = set_folder_by_barcode
      if @folder
        redirect_to(@folder)
      else
        redirect_to :back, notice: "No Folder with barcode \"#{params[:barcode]}\" found."
      end
    else
        @folders = PulStore::Lae::Folder.all
    end
  end

  # GET /lae/folders/1
  # GET /lae/folders/1.json
  def show
  end

  # GET /lae/folders/new
  def new
   @folder = PulStore::Lae::Folder.new
  end

  # # GET /lae/folders/1/edit
  def edit
  end

  # POST /lae/folders
  # POST /lae/folders.json
  def create
    @folder = PulStore::Lae::Folder.new(folder_params)

    respond_to do |format|
      if @folder.save
        format.html { redirect_to @folder, notice: 'Folder was successfully created.' }
        format.json { render action: 'show', status: :created, location: @folder }
      else
        format.html { render action: 'new' }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lae/folders/1
  # PATCH/PUT /lae/folders/1.json
  def update
    respond_to do |format|
      if @folder.update(folder_params.except('project_pid'))
        format.html { redirect_to @folder, notice: 'Folder was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lae/folders/1
  # DELETE /lae/folders/1.json
  def destroy
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
      PulStore::Lae::Folder.where(prov_metadata__barcode_tesim: params[:barcode]).first
    end

    def folder_params
      params.require(:lae_folder).permit(:barcode, :date_created, :description,
        :extent, :genre, :passed_qc, :rights, :sort_title, :suppressed, :title,
        :box_id, :project_id, alternative_title: [], geographic: [], 
        language: [], publisher: [], series: [], subject: [])

    end
end
