# frozen_string_literal: true
class NotificationsController < ApplicationController
  # generally dangerious but this controller holds webhooks
  skip_before_action :verify_authenticity_token, only: %i(coinbase mover urdubit)

  def coinbase
    # If the secret is incorrect, drop it like it's hot
    unless params[:secret] == Rails.application.secrets.coinbase_webhook_secret
      return render json: { success: false, message: 'Invalid secret' }
    end
    # If the secret's good, just keep going
    address = params['data']['address']
    amount = params['additional_data']['amount']['amount']
    coinbase_id = params['additional_data']['transaction']['id']

    btc_address = BtcAddress.find_by(address: address)
    btc_address.btc_txes << BtcTx.new(amount: amount, coinbase_id: coinbase_id)
    render json: { success: true, message: 'Transaction noted' }
  end

  def mover
    unless params[:secret] == Rails.application.secrets.mover_webhook_secret
      logger.info('Invalid secret for mover recieved')
      return render json: { success: false, message: 'Invalid secret' }
    end
    # If the secret's good, just keep going
    UpdateBtcTxStatusJob.perform_now
    render json: { success: true, message: 'Job being performed' }
  end

  def urdubit
    unless params[:secret] == Rails.application.secrets.urdubit_secret
      logger.info('Invalid secret for mover recieved')
      return render json: { success: false, message: 'Invalid secret' }
    end
    # If the secret's good, just keep going
    trade_id = params['payload']['OrderID']
    quantity = params['payload']['CumQty'].to_d
    price = params['payload']['AvgPx'].to_d

    execution_price = ((quantity * price) / 1e16).round
    spot_trade_fee = (execution_price.to_d * 25 / 10_000).ceil
    net_execution_price = execution_price - spot_trade_fee
    withdrawal_fee = (net_execution_price * 1.to_d / 100).ceil
    withdrawal_amount = net_execution_price - withdrawal_fee

    payload_fee = (withdrawal_amount * 1.to_d / 100).ceil
    net_withdrawal_amount = withdrawal_amount - payload_fee

    BtcTx.find_by(trade_id: trade_id).confirm_trade(net_withdrawal_amount)
  end
end
