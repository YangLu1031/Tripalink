ActiveAdmin.register CarTransaction do

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
    column :total_amount
    column :buyer
    column :seller
    column :car
    column :expert
    column :status
    actions
  end

  filter :status, :as => :select
  filter :expert_name, :as => :string
  filter :seller_name, :as => :string
  filter :buyer_name, :as => :string
  filter :total_amount, :as => :numeric
  filter :car_car_model_year, :as => :numeric, :label => 'Year'
  filter :car_car_model_make, :as => :string, :label => 'Make'
  filter :car_car_model_model, :as => :string, :label => 'Model'
  filter :car_car_model_trim, :as => :string, :label => 'Trim'



end
