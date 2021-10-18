# Copyright (c) 2021 Brandon Zimmerman
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

defmodule Matic.Filesystem do
  @moduledoc """
  Groups utility functions related to the filesystem.
  """

  require Logger

  ## Constructing Dir Paths ##

  @spec main_dir(Path.t()) :: Path.t()
  def main_dir(sub_dir \\ "") do
    Application.fetch_env!(:matic, :main_dir)
    |> Path.expand()
    |> Path.join(sub_dir)
  end

  @spec plugins_dir(Path.t()) :: Path.t()
  def plugins_dir(file \\ ""),
    do: Path.join(main_dir("plugins"), file)

  @spec data_dir(Path.t()) :: Path.t()
  def data_dir(file \\ ""),
    do: Path.join(main_dir("data"), file)

  ## Requiring Dirs ##

  @doc """
  Creates a directory with the given `path` unless it already exists.
  """
  @spec require_dir(Path.t()) :: :ok
  def require_dir(path) when is_binary(path) do
    if File.dir?(path) do
      :ok
    else
      Logger.info("Directory #{inspect(path)} doesn't exist. Creating…")
      File.mkdir!(path)
    end
  end

  def require_main_dir,
    do: require_dir(main_dir())

  def require_plugins_dir,
    do: require_dir(plugins_dir())

  def require_data_dir,
    do: require_dir(data_dir())

  ## File IO ##

  @spec read_with_checksum(Path.t()) :: {checksum :: binary, contents :: binary}
  def read_with_checksum(path) do
    contents = File.read!(path)
    checksum = Matic.checksum(contents)
    {checksum, contents}
  end

  @spec list_plugins() :: [Path.t()]
  def list_plugins do
    plugins_dir("*.exs")
    |> Path.wildcard()
  end
end
