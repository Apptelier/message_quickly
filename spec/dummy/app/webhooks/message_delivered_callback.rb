class MessageDeliveredCallback < MessengerPlatform::Callback

  def callback_name
    :message_deliveries
  end

  def run(event, json)
  end

end
