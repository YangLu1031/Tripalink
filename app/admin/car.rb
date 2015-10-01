ActiveAdmin.register Car do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end

  index do
    selectable_column
    id_column
    column :owner
    column :expert
    column 'year' do |f|
      f.car_model.year
    end
    column 'make' do |f|
      f.car_model.make
    end
    column 'model' do |f|
      f.car_model.model
    end
    column 'trim' do |f|
      f.car_model.trim
    end
    column :status do |f|
      if f.status == 0
        'default'
      elsif f.status == 1
        'pre_inspected'
      elsif f.status == 2
        'inspected'
      elsif f.status == 3
        'listing for sale'
      elsif f.status == 4
        'sale pending'
      elsif f.status == 5
        'sold'
      else
        'deleted'
      end
    end
    actions
  end

  filter :car_model_year, :as => :numeric
  filter :car_model_make, :as => :string
  filter :car_model_model, :as => :string
  filter :car_model_trim, :as => :string
  filter :status, :as => :select
  filter :owner_name, :as => :string
  filter :expert_name, :as => :string


  controller do
    def permitted_params
      params.permit car: []
    end
  end
end
