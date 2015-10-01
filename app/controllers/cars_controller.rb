class CarsController < ApplicationController
  before_action :set_car, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, only: [:checklist]

  # GET /cars
  # GET /cars.json
  def index
    params[:search] ||= {}
    params[:search].each { |key, value|
      # parse_attribute(key, value)
      if !value.nil? && value.is_a?(String)
        #value.gsub!(/[Mm][Ii][Nn]/, '0')
        #value.gsub!(/[Mm][Aa][Xx]/, '999999')
      end
    }
    params["search"].delete_if {|key, value|
      if (key == "car_model.make" || key == "car_model.model")
        false
      else
        (value.size == 3 && (value =~ /[Mm][Ii][Nn]/ || value =~ /[Mm][Aa][Xx]/)) ? true : false
      end
    }
    params["search"] = params["search"].merge("status" => [3, 4, 5])
    @search = Search.new(Car, params[:search])
    @cars = @search.run(params[:page]).where(sold: false).order("status, created_at DESC")
    # debugger
    # @models = CarModel.pluck('DISTINCT make, model')
    respond_to do |format|
      format.html { render 'index' }
      format.json { render json: @cars }
    end
  end

  # GET /cars/1
  # GET /cars/1.json
  def show
    if @car.checklist and @car.checklist.size > 0
      @checklistdefinition = getChecklistDefinition(@car.checklist[0])
    else
      @checklistdefinition = nil
    end
    print 'hello'
  end

  # GET /cars/new
  def new
    @car = Car.new
  end

  # GET /cars/1/edit
  def edit
    @car = Car.find(params[:id])
    @checklistdefinition = getChecklistDefinition()
    @default_values = get_checkitem_default_values(@checklistdefinition)
    @check_item_index = get_check_item_index(@checklistdefinition)
  end

  # POST /cars
  # POST /cars.json
  def create
    @car = Car.new(car_params)

    respond_to do |format|
      if @car.save
        format.html { redirect_to @car, notice: 'Car was successfully created.' }
        format.json { render :show, status: :created, location: @car }
      else
        format.html { render :new }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cars/1
  # PATCH/PUT /cars/1.json
  def update
    # Update basic params
    @car.update_attributes(car_basic_params)
    # Update car's color
    color_params = car_color_params
    color_params.each do |color_type, color_name|
      color = CarColor.find_by_name(color_name)
      if color_type == "interior_color"
        @car.interior_color = color
      else
        @car.exterior_color = color
      end
    end

    # Update car's features
    feature_params = car_feature_params
    features = []
    feature_params.each do |feature_name, feature_selected|
      if feature_selected == "1"
        feature = CarFeature.find_by_name(feature_name)
        features << feature
      end
    end
    @car.features = features

    # Update car's checklists
    @check_item_index = get_check_item_index(getChecklistDefinition())
    checklist_params = car_checklist_params
    new_checklist = []
    checklist_params.each do |item_name, item_val|
      new_checklist[@check_item_index[item_name]] = item_val
    end
    @car.checklist = new_checklist
    # Update the status of car
    @car.status = 2

    @car.save
    redirect_to edit_car_path(@car)
  end

  # DELETE /cars/1
  # DELETE /cars/1.json
  def destroy
    @car.destroy
    respond_to do |format|
      format.html { redirect_to cars_url, notice: 'Car was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #GET /cars/models?make=Porsche
  def models
    @car_models = CarModel.where(make: params[:make]).order(:model).pluck("DISTINCT model")
    # debugger
  end

  #GET /cars/bodystyles?make=Porsche&model=
  def bodystyles
    @bodystyles = CarModel.where(make: params[:make], model: params[:model]).order(:body).pluck("DISTINCT body")
  end

  #GET /cars/styletrims?styleIds=101355672,101355906,101355720,101355908
  def styletrims
    styleIds = params[:styleIds].split(',')
    legitIds = styleIds.select{ |i| i.to_i != 0 }.map{ |i| i.to_i }
    @trims = CarModel.where(styleId: legitIds).map{ |v| v.trim }
  end

  #
  def fetch
    plate = params["plate"]
    state = params["state"]
    fetcher = CarsHelper::VINFetcher.new
    vin = fetcher.fetchVINWithPlate(params[:plate], params[:state])
    if !vin || vin == ""
      return @styleId = "Failed to get VIN."
    end
    puts vin
    styleId = fetcher.fetchModelIdWithVIN(vin)
    puts styleId
    # debugger
    @car_model = CarModel.find_by(styleId: styleId)
    @styleId = styleId
  end

  def checklistdefinition
    ver = params[:version] || "latest"
    @checklist = getChecklistDefinition(ver)
    render json: @checklist
  end

  def checklist
    @car = Car.find(params[:id])
    if request.get?
      @checklist = @car.checklist
      render json: @checklist
    elsif request.post?
      json = params[:_json]
      if json.nil? or json.class != Array or json.size < 1 or getChecklistDefinition(json[0]) == nil
        respond_to do |format|
          format.json { render json: {message: "format error"}, status: :unprocessable_entity }
        end
        return
      end
      checklist = getFlatChecklistDefinition(json[0])
      if checklist.size + 1 != json.size
        respond_to do |format|
          format.json { render json: {message: "array size error"}, status: :unprocessable_entity }
        end
        return
      end
      @car.checklist = json
      respond_to do |format|
        if @car.save
          format.html { redirect_to cars_url(params[:id]), notice: 'The checklist of the car was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { redirect_to cars_url(params[:id]), notice: 'Fail to update the checklist of the car.' }
          format.json { render json: {message: "format error"}, status: :unprocessable_entity }
        end
      end
    end
  end

  def craigslist
    cl = CraigslistBot.new(Car.find(params[:id]))
    cl.main
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_car
      @car = Car.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def car_params
      params[:car]
    end

    def car_basic_params
      params.require(:car).permit(:mileage)
    end

    def car_color_params
      params.require(:car).permit(:interior_color, :exterior_color)
    end

    def car_feature_params
      params.require(:feature).permit!
    end

    def car_checklist_params
      params.require(:checklist).permit!
    end

    # def car_basic_info_params
    #   params.require(:car).permit(:mileage)
    # end


    def getChecklistDefinition(version = "latest")
      if version == "latest" or version.nil?
        version = CONFIG_CHECKLIST["latest"]
      end
      CONFIG_CHECKLIST[version]
    end
    helper_method :getChecklistDefinition

    def getFlatChecklistDefinition(version= "latest")
      getChecklistDefinition(version).map{ |section|
        section["values"].each { |s|
          s["section"] = section["section"]
        }
        section["values"]
      }.flatten
    end

    def get_check_item_index(checklist_definition)
      check_item_index = {}
      idx = 0
      checklist_definition.each do |section|
        section["values"].each do |item|
          check_item_index[item["name"]] = idx
          idx += 1
        end
      end
      check_item_index
    end

    def get_checkitem_default_values(checklist_definition)
      default_values = []
      checklist_definition.each do |section|
        section["values"].each do |item|
          if item["type"] == "boolean"
            default_values << "1"
          else
            default_values << "0"
          end
        end
      end
    end
end
