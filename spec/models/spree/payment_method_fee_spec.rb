require 'spec_helper'

describe Spree::PaymentMethodFee do
  let(:payment_profiles_supported) { true }
  before(:each) { allow_any_instance_of(Spree::PaymentMethod).to receive(:payment_profiles_supported?).and_return(payment_profiles_supported) }
  let(:payment_method) { create :check_payment_method }
  let(:payment_method_fee) { Spree::PaymentMethodFee.new( payment_method: payment_method, amount: 1, currency: 'USD' ) }

  describe 'creating a payment method fee' do

    context 'with an payment method that supports payment profiles' do
      it { expect(payment_method_fee.save).to eq true }

      context 'when a fee already exists on the payment method with the same currency' do
        before do
          Spree::PaymentMethodFee.create(
            payment_method: payment_method,
            amount: 1,
            currency: 'USD'
          )
        end
        it { expect(payment_method_fee.save).to eq false }
      end
    end

    context 'with an payment method that doesnt support payment profiles' do
      let(:payment_profiles_supported) { false }
      it { expect(payment_method_fee.save).to eq false }
    end
  end

  context '.apply_adjustment_to_order' do
    let(:order) { create :order }
    let(:payment_profiles_supported) { true }
    let(:fee) { Spree::PaymentMethodFee.create( payment_method: payment_method, currency: 'USD', amount: 200 ) }

    before do
      # create a 'fee' to verify it gets blown away when we call adjust
      order.adjustments.create amount: 10, label: Spree.t('fee')
      allow(order).to receive(:payment_method).and_return(payment_method)

      fee.add_adjustment_to_order(order)
    end

    context "with existing fees" do
      subject { order.adjustments.where(label: Spree.t('fee')) }

      specify { expect(subject.size).to eq(1) }
      specify { expect(subject.first.amount).to eq(200) }
      specify { expect(subject.first.label).to eq(Spree.t('fee')) }
    end
  end

  context '.add_adjustment_to_order' do
    let(:order) { create :order_with_line_items }
    let(:payment_profiles_supported) { false }
    let(:fee) { Spree::PaymentMethodFee.create( payment_method: payment_method, currency: 'USD', amount: 200 ) }
    before do
      fee.add_adjustment_to_order(order)
    end

    subject { order }
    specify { expect(subject.adjustments.size).to eq(1) }
    specify { expect(subject.adjustments.first.label).to eq(Spree.t("fee")) }
  end
end
