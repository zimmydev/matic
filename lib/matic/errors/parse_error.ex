# Copyright (c) 2021 Brandon Zimmerman
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

defmodule Matic.Error.ParseError do
  defexception [:message]

  @impl Exception
  def exception(reason),
    do: %__MODULE__{message: message_for(reason)}

  defp message_for({:unrecognized_switch, switch}),
    do: "unrecognized switch #{inspect(switch)}"

  defp message_for({:unrecognized_plugin, plugin}),
    do: "cannot find a plugin named #{inspect(plugin)}"
end
