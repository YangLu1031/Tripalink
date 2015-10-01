class DriverLicenseController < ApplicationController
  def index
  end

  def show
    if params[:id] == "1"
      @questions = ((0...148).to_a.sample(36) + (148...175).to_a.sample(12)).map{|i| CONFIG_TESTS[0]["questions"][i] }
    # elsif params[:id] == "2"
    else
      @questions = CONFIG_TESTS[0]["questions"]
    end
  end

  def game
    @questions = CONFIG_TESTS[0]["questions"].values_at(112, 45, 122, 137, 55, 4, 71, 85, 132, 96)
    render :layout => false
  end

  def test
    @questions = ((0...148).to_a.sample(36) + (148...175).to_a.sample(12)).map{|i| CONFIG_TESTS[0]["questions"][i] }
  end

  def practice
    @questions = CONFIG_TESTS[0]["questions"]
  end
end
