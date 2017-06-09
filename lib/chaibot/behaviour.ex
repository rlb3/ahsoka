defmodule Chaibot.Behaviour do
  @callback match?(String.t) :: any
  @callback run(String.t, keyword) :: any
end
