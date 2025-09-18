class CustomernotesController < ApplicationController
  def create
    @note = Customernote.new(params[:customernote])
    @note.user_id = current_user.id if defined?(current_user) && current_user

    if @note.save
      render json: {
        success: true,
        note: {
          id: @note.id,
          description: @note.description,
          created_at: @note.created_at.strftime("%Y-%m-%d %H:%M:%S")
        }
      }
    else
      render json: { success: false, errors: @note.errors.full_messages }, :status => :unprocessable_entity
    end
  end

  def destroy
    @customer_note = Customernote.find_by_id(params[:id])
    if @customer_note
      @customer_note.update_attributes(:deleted => true, :deleteuser_id => current_user.id)
      render json: { success: true, id: @customer_note.id }
    else
      render json: { success: false }, :status => :not_found
    end
  end
end