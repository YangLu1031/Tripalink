class CarModelsController < ApplicationController

  def models
    #TODO improve search function
    @makes_and_models = CarModel.where("model ILIKE '#{params['val']}%' or make ILIKE '#{params['val']}%'").order('make').pluck('distinct make, model')
  end

  def years
    @years = CarModel.where(make: "#{params['make']}", model: "#{params['model']}").order('year').pluck('distinct year')
  end

  def stylenames
    @stylenames = CarModel.where(make: "#{params['make']}", model: "#{params['model']}", year: "#{params['year']}").pluck('distinct "styleName", "styleId", "body"').sort
  end

  def get_make
    @makes = CarModel.where(year: "#{params['year']}").order('make').pluck('distinct make')
  end

  def get_model
    @models = CarModel.where(year: "#{params['year']}", make: "#{params['make']}").order('model').pluck('distinct model')
  end

  def get_body
    @bodies = CarModel.where(year: "#{params['year']}", make: "#{params['make']}", model: "#{params['model']}").pluck('distinct body')
  end

  def get_trim
    @trim = CarModel.where(year: "#{params['year']}", make: "#{params['make']}", model: "#{params['model']}", body: "#{params['body']}").pluck('distinct trim')
  end

  def get_drivetrain
    @drivetrain = CarModel.where(year: "#{params['year']}", make: "#{params['make']}", model: "#{params['model']}", body: "#{params['body']}", trim: "#{params['trim']}").pluck('distinct "driveTrain"').sort
  end

  def get_transmission
    @transmission = CarModel.where(year: "#{params['year']}", make: "#{params['make']}", model: "#{params['model']}", body: "#{params['body']}", trim: "#{params['trim']}", driveTrain: "#{params['drivetrain']}").pluck('distinct transmission, "styleId", id').sort
  end

end
