# First task of Thinknetica Rails-app design workshop

## Task description

Ваше приложение — онлайн магазин. Бизнес выяснил, что при оформлении заказа много времени тратится на оформление документов на доставку и просит автоматизировать процесс. 

Считайте, что у вас есть класс, который оформляет документы

```ruby
Sdek.setup_delivery(address:, person:, weight:)
```

Результат выполнения — хеш

```
 { result: [‘succeed’, ‘failed’] }
```

Надо сделать запрос на доставку сразу после оформления заказа, результат сохранить в базе, оповестить пользователя о том, что доставка оформлена.

Решите, какой подход вы будете использовать? Где будет жить логика оформления доставки? как будете обрабатывать ошибки? что будете делать, если сторонний сервис недоступен?

Создайте пустое rails приложение без вьюх

```bash
rails new --api -T delivery-app
```

Разнесите логику платежей из контроллера и доработайте так, чтобы в этом флоу появилась оформление доставки

```ruby
class PaymentsController < ApplicationController
  def create
    product = Product.find(params[:product_id])
    payment_result = CloudPayment.proccess(
      user_uid: current_user.cloud_payments_uid,
      amount_cents: params[:amount] * 100,
      currency: 'RUB'
    )

    if payment_result[:status] == 'completed'
      product_access = ProductAccess.create(user: current_user, product:)
      OrderMailer.product_access_email(product_access).deliver_later
      redirect_to :successful_payment_path
    else
      redirect_to :failed_payment_path, note: 'Что-то пошло не так'
    end
  end
end
```
