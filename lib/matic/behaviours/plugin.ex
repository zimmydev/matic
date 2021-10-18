# Copyright (c) 2021 Brandon Zimmerman
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

defmodule Matic.Plugin do
  @moduledoc """
  The contract for a Matic plugin.
  """

  @typedoc """
  The argument vector; i.e., a list of string arguments given to the plugin.
  """
  @type argv :: [String.t()]

  @callback run(cwd :: Path.t(), args :: argv) :: :ok
  @callback version() :: String.t()
  @callback description() :: String.t()
  @callback help() :: String.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
      import unquote(__MODULE__),
        only: [
          version: 1,
          description: 1,
          help: 1
        ]

      alias unquote(__MODULE__)
    end
  end

  defmacro version(semver) when is_binary(semver) do
    quote do
      @impl unquote(__MODULE__)
      def version, do: unquote(semver)
    end
  end

  defmacro description(message) when is_binary(message) do
    quote do
      @impl unquote(__MODULE__)
      def description, do: unquote(message)
    end
  end

  defmacro help(message) when is_binary(message) do
    quote do
      @impl unquote(__MODULE__)
      def help, do: unquote(message)
    end
  end
end
