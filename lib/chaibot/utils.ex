defmodule Chaibot.Utils do
  def send_message(text, slack, message) do
    send slack, {:message, text, message.channel}
  end
end
