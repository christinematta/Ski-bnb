class SkisController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  def index
    if params[:query].present?
      sql_subquery = "brand ILIKE :query OR experience_level ILIKE :query"
      @skis = Ski.where(sql_subquery, query: "%#{params[:query]}%")
    else
      @skis = Ski.all
    end

    @markers = @skis.geocoded.map do |ski|
      {
        lat: ski.latitude,
        lng: ski.longitude
      }
    end
  end

  def show
    @ski = Ski.find(params[:id])
  end

  def new
    @ski = Ski.new
  end

  def create
    @ski = Ski.new(ski_params)
    @ski.user = current_user
    if @ski.save
      redirect_to skis_path
      # redirect_to ski_path(@ski)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def ski_params
    params.require(:ski).permit(:brand, :experience_level, :size, :daily_price, :location, :photo)
  end
end
