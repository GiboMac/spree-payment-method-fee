module Spree
  OrderUpdateAttributes.class_eval do

    def initialize(order, attributes, request_env: nil)
      @order = order
      @attributes = attributes.dup
      @payments_attributes = @attributes.delete(:payments_attributes) || []
      @request_env = request_env

      return if @payments_attributes.empty?

      destroy_fee_adjustments_for_order

      payments_attributes.each do |payment|
        payment_method = PaymentMethod.find(payment[:payment_method_id])
        payment_method.fees.where(currency: @order.currency).first.try do |fee|
          fee.add_adjustment_to_order(@order)
        end
      end

      @order.update_totals
      @order.adjustments.reload
    end

    def destroy_fee_adjustments_for_order
      fee_adjustments.destroy_all
    end

    def fee_adjustments
      @order.adjustments.where( label: 'fee' )
    end
  end
end
