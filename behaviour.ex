defmodule Chaibot.Behaviour do
  @callback match?(String.t, any) :: any
  @callback run(String.t, keyword) :: any
end
