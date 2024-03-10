class Connection

  def publish_message(message)
    json_message = message.to_json
    publish('input_handle_channel', json_message)
  end

  def send_disonnect
    publish_message({type: 'disconnect', id: @client_id})
  end
end
