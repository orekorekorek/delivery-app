class DeliveryForm
  include ActiveModel::Model

  validates :user, presence: true
  validates :product, presence: true
  validates :address, presence: true

  validate :setup_delivery

  def call
    return notify_user unless valid?

    notify_user
  end

  private

  def setup_delivery
    setup = delivery_operator.setup_delivery(address: address, person: user, weight: product.weight)

    errors.add(:delivery_setup, 'Delivery setup failed') if setup[:result] == 'failed'
  rescue HTTP::Error
    errors.add(:delivery_setup, 'Delivery operator is unreachable')
  end

  def notify_user
    OrderMailer.product_delivery_email(mailer_params).deliver_later
  end

  def mailer_params
    params = {
      address: address,
      user: user,
      product: product
    }

    params.merge(details: errors) if errors.present? # We need to notify user if there are some errors with delivery
  end

  def delivery_operator
    Sdek
  end
end
