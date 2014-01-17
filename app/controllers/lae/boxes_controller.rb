class Lae::BoxesController < ApplicationController
  before_action :set_box, only: [:show, :edit, :update, :destroy]

  def index
    if params[:barcode]
      @box = get_box_by_barcode
      if @box
        redirect_to(@box)
      else
        redirect_to :back, notice: "No Box with barcode &quot;#{params[:barcode]}&quot; found."
      end
    else
        @boxes = PulStore::Lae::Box.all
    end
  end

  # GET /boxes/1
  # GET /boxes/1.json
  def show
  end

  # GET /boxes/new
  # def new
  #  @box = PulStore::Box.new
  # end

  # # GET /boxes/1/edit
  # def edit
  # end

  # # POST /boxes
  # # POST /boxes.json
  # def create
  #   @box = PulStore::Box.new(box_params)

  #   respond_to do |format|
  #     if @box.save
  #       format.html { redirect_to @box, notice: 'Box was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @box }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @box.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /boxes/1
  # # PATCH/PUT /boxes/1.json
  # def update
  #   respond_to do |format|
  #     if @box.update(box_params.except('project_pid'))
  #       format.html { redirect_to @box, notice: 'Box was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @box.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /boxes/1
  # # DELETE /boxes/1.json
  # def destroy
  #   @box.destroy
  #   respond_to do |format|
  #     format.html { redirect_to pul_store_boxes_url }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_box
      @box = PulStore::Lae::Box.find(params[:id])
    end

    def get_box_by_barcode
      PulStore::Lae::Box.where(prov_metadata__barcode_tesim: params[:barcode]).first
    end

    # Never trust parameters from the scary internet, only allow the 
    # white list through.

    def box_params

      params.require(:lae_box).permit(:full, :barcode, :error_note, 
        :physical_location, :tracking_number, :shipped_date, :received_date, 
        :project_id)

    end
end
