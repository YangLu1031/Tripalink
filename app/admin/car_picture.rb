ActiveAdmin.register CarPicture do

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

  # form do |f|
  #   f.inputs 'Car Pictures' do
  #     f.input :car
  #     f.input :picture
  #   end
  #   f.actions
  # end

  controller do
    def permitted_params
      params.permit car_picture: [:car, :picture]
    end
  end

end
