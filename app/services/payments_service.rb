class PaymentsService
  def initialize(product:, user:, amount:, payment_gateway: CloudPayment)
    @product = product
    @user = user
    @amount_cents = amount * 100
    @payment_gateway = payment_gateway
  end

  def call
    make_purchase!
  end

  private

  attr_reader :product, :user, :amount_cents, :payment_gateway

  def make_purchase!
    payment_result = payment_gateway.proccess(
      user_uid: user.cloud_payments_uid,
      amount_cents:,
      currency: 'RUB'
    )
    notify_user if payment_result[:status] == 'completed'

    payment_result
  end

  def product_access
    ProductAccess.create(user:, product:)
  end

  def notify_user
    OrderMailer.product_access_email(product_access).deliver_later
  end
end
