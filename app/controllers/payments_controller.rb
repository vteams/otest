class PaymentsController < ApplicationController
  # GET /payments
  # GET /payments.json
  def index
    @payments = Payment.unarchived.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
    @payment = Payment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payment }
    end
  end

  # GET /payments/new
  # GET /payments/new.json
  def new
    @payment = Payment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payment }
    end
  end

  # GET /payments/1/edit
  def edit
    @payment = Payment.find(params[:id])
  end

  # POST /payments
  # POST /payments.json
  def create
    @payment = Payment.new(params[:payment])

    respond_to do |format|
      if @payment.save
        format.html { redirect_to @payment, notice: 'The payment has been recorded successfully.' }
        format.json { render json: @payment, status: :created, location: @payment }
      else
        format.html { render action: "new" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /payments/1
  # PUT /payments/1.json
  def update
    @payment = Payment.find(params[:id])

    respond_to do |format|
      if @payment.update_attributes(params[:payment])
        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to payments_url }
      format.json { head :no_content }
    end
  end
  def enter_payment
    @payments = []
    params[:invoice_ids].each do |inv_id|
      payment = Payment.new
      payment.invoice_id = inv_id
      @payments << payment
    end
  end
  def update_individual_payment
    params[:payments].each do |pay|
      pay[:payment_amount] = Payment.update_invoice_status pay[:invoice_id], pay[:payment_amount].to_i
      Payment.create!(pay).notify_client
    end
    redirect_to(payments_url,:notice => 'The payment has been recorded successfully.')
    #redirect_to payments_url
  end
  
  def bulk_actions
    if params[:archive]
      Payment.archive_multiple(params[:payment_ids])
      @payments = Payment.unarchived.page(params[:page])
      @action = "archived"
    elsif params[:destroy]
      Payment.delete_multiple(params[:payment_ids])
      @payments = Payment.unarchived.page(params[:page])
      @action = "deleted"
    elsif params[:recover_archived]
      Payment.recover_archived(params[:payment_ids])
      @payments = Payment.archived.page(params[:page])
      @action = "recovered"
    elsif params[:recover_deleted]
      Payment.recover_deleted(params[:payment_ids])
      @payments = Payment.only_deleted.page(params[:page])
      @action = "recovered"
    end
    respond_to { |format| format.js }
  end

  def filter_payments
    @payments = Payment.filter(params)
  end

end
