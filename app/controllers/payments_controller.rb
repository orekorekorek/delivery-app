class PaymentsController < ApplicationController
  def create
    product = Product.find(params[:product_id])
    payment_result = PaymentsService.new(product:, user: current_user, amount: purchase_params[:amount]).call

    if payment_result[:status] == 'completed'
      DeliveryForm.new(product:, user: current_user, address: delivery_params[:address]).call

      redirect_to :successful_payment_path
    else
      redirect_to :failed_payment_path, 'Что-то пошло не так'
    end
  end

  private

  def delivery_params
    params.permit(:address)
  end

  def purchase_params
    params.permit(:amount)
  end
end
