require 'json'

class PagesController < ApplicationController
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  # GET /pages
  # GET /pages.json
  def index
    @pages = Page.all
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # GET /pages/1/edit
  def edit
  end

  # POST /pages
  # POST /pages.json
  def create

    respond_to do |format|
        format.html do
          @page = Page.new(page_params)
          if @page.save
            redirect_to @page, notice: 'Page was successfully created.'
          else
            render action: 'new'
          end
        end

        format.json do

          r = {}
          r[:files] = []

          params[:text][:pages].each do |p|

            @page = Page.new(type:"Page", sort_order:1)


            uploaded_io = p

            stage_path = Page.upload_to_stage(uploaded_io, uploaded_io.original_filename)

            filesize = File.size(stage_path)

            r[:files] << {
                :name => p.original_filename,
                :type => p.content_type,
                :size => filesize,
                :url => url_for(@page),
                :delete_url => '',
                :delete_type => ''
            }

          end

          render text: r.to_json, status: :created, location: @page
        end

    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to @page, notice: 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page.destroy
    respond_to do |format|
      format.html { redirect_to pages_url }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params.require(:page).permit(:label, :type, :sort_order)
    end



end
