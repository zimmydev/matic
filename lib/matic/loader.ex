# Copyright (c) 2021 Brandon Zimmerman
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

defmodule Matic.Loader do
  @moduledoc """
  Responsible for conditionally compiling and then memoizing the bytecode of the plugin modules.
  """

  require Logger

  alias Matic.Filesystem

  ## Memoization ##

  @spec load_memo() :: map
  def load_memo do
    path = memo_path()

    if File.regular?(path) do
      # Memo exists
      contents = File.read!(path)

      try do
        :erlang.binary_to_term(contents)
      rescue
        ArgumentError ->
          # Memo exists but has been corrupted
          Logger.info("The memo file has been corrupted; creating a new one…")
          new_memo()
      end
    else
      # Memo does not exist
      new_memo()
    end
  end

  @spec rebuild_memo(map) :: map
  def rebuild_memo(memo) when is_map(memo) do
    plugins = Filesystem.list_plugins()

    for {name, path, checksum, contents} <- Enum.map(plugins, &read_plugin/1), into: %{} do
      case Map.get(memo, name) do
        {^checksum, compilation} ->
          Logger.debug("Bytecode for #{inspect(name)} was cached; loading into BEAM…")
          load_into_beam(compilation, path)

          {name, {checksum, compilation}}

        _ ->
          # The file is new, compilation was stale, or last open attempt produced an error
          Logger.debug("Compiling #{inspect(name)}…")

          {name, {Matic.checksum(contents), compile(contents, path)}}
      end
    end
  end

  @spec write_memo(map) :: map
  def write_memo(memo) when is_map(memo) do
    path = memo_path()
    serialized_memo = :erlang.term_to_binary(memo)
    File.write!(path, serialized_memo)
    memo
  end

  ## Memoization Helpers ##

  @spec memo_path() :: Path.t()
  defp memo_path,
    do: Filesystem.data_dir("memo")

  @spec new_memo() :: map
  defp new_memo,
    do: write_memo(%{})

  @spec read_plugin(Path.t()) ::
          {name :: String.t(), Path.t(), checksum :: binary, contents :: binary}
  defp read_plugin(path) do
    name = extract_plugin_name(path)
    {checksum, contents} = Filesystem.read_with_checksum(path)
    {name, path, checksum, contents}
  end

  @spec extract_plugin_name(Path.t()) :: String.t()
  defp extract_plugin_name(path),
    do: Path.basename(path, ".exs")

  ## Memo Access ##

  @spec main_module(map, plugin :: String.t()) :: module
  def main_module(memo, plugin) do
    {_checksum, compilation} = Map.fetch!(memo, plugin)
    [{main_module, _bytecode} | _other_compiled_modules] = compilation
    main_module
  end

  ## Compilation & Loading ##

  @spec compile(binary, Path.t()) :: [{module, binary}]
  def compile(contents, path),
    do: Code.compile_string(contents, path)

  @spec load_into_beam([{module, binary}], Path.t()) :: :ok
  def load_into_beam(compilation, path) do
    Enum.each(compilation, fn {module, bytecode} ->
      :code.load_binary(module, String.to_charlist(path), bytecode)
    end)
  end
end
