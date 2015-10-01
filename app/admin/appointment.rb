ActiveAdmin.register Appointment do

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
    column :appointment_type
    column :address
    column :city
    column :time_window
    actions
  end

  filter :appointment_type, :as => :select
  filter :address, :as => :string
  filter :time_window, :as => :select
  filter :zipcode


  controller do
    def permitted_params
      params.permit appointment: [:expert, :user, :address, :city, :state, :zipcode]
    end
  end

end
