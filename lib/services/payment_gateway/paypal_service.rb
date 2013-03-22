class PaypalService
  attr_accessor :invoice_id, :invoice, :client, :amount, :credit_card, :purchase_options

  #  options => {invoice_id: id}
  #  options => invoice_id
  def initialize(options)
    @invoice_id = options.is_a?(Hash) ? options[:invoice_id] : options
    @invoice = Invoice.find_by_id(@invoice_id)
    return nil unless @invoice
    @client = @invoice.client

    prepare_payment
  end

  def process_payment
    return OSB::Paypal::TransStatus::ALREADY_PAID if @invoice.paid?

    if @credit_card.valid?
      response = OSB::Paypal::gateway.authorize(@amount, @credit_card, @purchase_options)
      if response.success?
        OSB::Paypal::gateway.capture(@amount, response.authorization)
        {status: OSB::Paypal::TransStatus::SUCCESS, amount_in_cents: @amount}
      else
        {status: OSB::Paypal::TransStatus::FAILED, message: response.message}
      end
    else
      {status: OSB::Paypal::TransStatus::INVALID_CARD, message: @credit_card.errors.fullmessages.join()}
    end
  end

  def prepare_payment
    @purchase_options = @client.purchase_options
    @credit_card = @client.get_credit_card
    @amount = ((@invoice.unpaid_amount || 0).to_f * 100).to_i
  end
end