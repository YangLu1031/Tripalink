ActiveAdmin.register Expert do

  permit_params

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
    column :name
    column :phone
    column :email
    actions
  end

  filter :name
  filter :phone
  filter :email


  form do |f|
    f.inputs "Expert Details" do
      f.input :name
      f.input :phone
      f.input :email
      f.input :experience
      f.input :address
      f.input :city
      f.input :state
      f.input :zipcode
      f.input :organization
      f.input :biograph
      f.input :rating
      f.input :avatar
      f.input :lat
      f.input :lng
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit expert: [:name, :phone, :email, :experience, :address, :city, :state, :zipcode, :rating, :password, :password_confirmation]
    end
  end

end
