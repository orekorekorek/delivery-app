class DeliveryForm
  include ActiveModel::Model

  validates :user, presence: true
  validates :product, presence: true
  validates :address, presence: true

  validate :setup_delivery

  def call
    validate!
    notify_user
  end

  private

  def setup_delivery
    setup = delivery_operator.setup_delivery(address:, person: user, weight: product.weight)

    errors.add(:delivery_setup, 'Delivery setup failed') if setup[:result] == 'failed'
  rescue HTTP::Error
    errors.add(:delivery_setup, 'Delivery operator is unreachable')
  end

  def notify_user
    OrderMailer.product_delivery_email(mailer_params).deliver_later
  end

  def mailer_params
    params = { address:, user:, product: }
    errors.present? ? params.merge(details: errors) : params # We need to notify user if there are some errors with delivery
  end

  def delivery_operator
    Sdek
  end
end
