class AddOrderStatusToBtcTxes < ActiveRecord::Migration[5.0]
  def change
    add_column :btc_txes, :trade_id, :integer, null: false
  end
end
