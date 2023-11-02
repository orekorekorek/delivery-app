class PaymentsController < ApplicationController
  before_action :set_product, only: :create

  def create
    payment_result = PaymentsService.new(product: @product, user: current_user).call

    if payment_result[:status] == 'completed'
      DeliveryForm.new(product: @product, user: current_user, address: delivery_params[:address]).call

      redirect_to :successful_payment_path
    else
      redirect_to :failed_payment_path, 'Что-то пошло не так'
    end
  end

  private

  def delivery_params
    params.permit(:address)
  end

  def set_product
    @product = Product.find(params[:product_id])
  end
end
