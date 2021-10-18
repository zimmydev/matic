# Copyright (c) 2021 Brandon Zimmerman
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

defmodule Matic do
  @moduledoc """
  This module houses core `matic` functionality.
  """

  alias Matic.Filesystem

  @checksum_method Application.compile_env!(:matic, :checksum_method)

  ## Filesystem Setup ##

  @spec setup() :: :ok
  def setup do
    Filesystem.require_main_dir()
    Filesystem.require_plugins_dir()
    Filesystem.require_data_dir()
  end

  ## Application Functions ##

  @spec version() :: String.t()
  def version do
    Application.spec(:matic, :vsn)
    |> List.to_string()
  end

  ## Utility Functions ##

  def checksum(binary),
    do: :crypto.hash(@checksum_method, binary)
end
