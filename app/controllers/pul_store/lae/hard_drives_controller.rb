class PulStore::Lae::HardDrivesController < ApplicationController
  include PulStore::Lae::BarcodeLookups
  before_action :set_hard_drive, only: [:show, :edit, :update, :destroy]

  def index
    if params[:barcode]
      @hard_drive = get_hard_drive_by_barcode
      if @hard_drive
        redirect_to(@hard_drive)
      else
        redirect_to :back, notice: "No Hard Drive with barcode \"#{params[:barcode]}\" found."
      end
    else
        @hard_drives = PulStore::Lae::HardDrive.all
    end
  end

  # GET /lae/hard_drives/1
  # GET /lae/hard_drives/1.json
  def show
  end

  # GET /lae/hard_drives/new
  def new
   @hard_drive = PulStore::Lae::HardDrive.new
  end

  # # GET /lae/hard_drives/1/edit
  def edit
  end

  # POST /lae/hard_drives
  # POST /lae/hard_drives.json
  def create
    @hard_drive = PulStore::Lae::HardDrive.new(hard_drive_params)

    respond_to do |format|
      if @hard_drive.save
        format.html { redirect_to @hard_drive, notice: 'Hard Drive was successfully created.' }
        format.json { render action: 'show', status: :created, location: @hard_drive }
      else
        format.html { render action: 'new' }
        format.json { render json: @hard_drive.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lae/hard_drives/1
  # PATCH/PUT /lae/hard_drives/1.json
  def update
    @hard_drive.remove_box = hard_drive_params[:remove_box]
    updates = hard_drive_params.except(:lae_box)
    updates[:box] = get_box_by_barcode(hard_drive_params[:lae_box][:barcode])
    respond_to do |format|
      if @hard_drive.update(updates)
        format.html { redirect_to @hard_drive, notice: notice }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @hard_drive.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lae/hard_drives/1
  # DELETE /lae/hard_drives/1.json
  def destroy
    respond_to do |format|
      if @hard_drive.destroy
        format.html { redirect_to lae_hard_drives_path, notice: 'Hard Drive was successfully deleted.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @hard_drive.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hard_drive
      @hard_drive = PulStore::Lae::HardDrive.find(params[:id])
    end

    def hard_drive_params
      params.require(:lae_hard_drive).permit(:barcode, :error_note, :remove_box, lae_box: [:barcode])
    end
end
