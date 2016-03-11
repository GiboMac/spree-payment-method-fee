Deface::Override.new(
  virtual_path: "spree/checkout/_payment",
  name: "checkout_payment_method_fees",
  replace: '#payment-method-fields',
  partial: "spree/checkout/payment_methods_with_fees",
  disabled: false
)

