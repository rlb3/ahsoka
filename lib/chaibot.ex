defmodule Chaibot do
  defmacro __using__(_opts) do
    quote do
      @behaviour Chaibot.Behaviour
      import Chaibot.Utils
    end
  end
end
