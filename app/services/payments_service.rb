class PaymentsService
  def initialize(product:, user:, payment_gateway: CloudPayment)
    @product = product
    @user = user
    @payment_gateway = payment_gateway
  end

  def call
    payment_result = gateway_purchase

    notify_user if payment_result[:status] == 'completed'

    payment_result
  end

  private

  attr_reader :product, :user, :payment_gateway

  def gateway_purchase
    payment_gateway.proccess(
      user_uid: user.cloud_payments_uid,
      amount_cents: params[:amount] * 100,
      currency: 'RUB'
    )
  end

  def product_access
    ProductAccess.create(user: user, product: product)
  end

  def notify_user
    OrderMailer.product_access_email(product_access).deliver_later
  end
end
