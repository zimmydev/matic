# Copyright (c) 2021 Brandon Zimmerman
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

defmodule Matic.CLI do
  @moduledoc """
  This module houses the main entrypoint to and exit from the program and the related logic for handling program exit. Finally, it is responsible for all functions related to parsing the argument vector and transforming it into an IR that can be passed along to another module for processing.
  """

  alias Matic.{Display, Loader}
  alias Matic.Error.ParseError

  @parse_options [
    strict: [
      help: :boolean,
      version: :boolean
    ],
    aliases: [
      {:h, :help},
      {:"?", :help},
      {:v, :version}
    ]
  ]

  @typep argv :: [String.t()]
  @typep parse_result :: {OptionParser.parsed(), OptionParser.argv(), OptionParser.errors()}
  @typep commandset :: {program :: String.t(), args :: argv}

  @spec main(argv) :: no_return
  def main(argv) when is_list(argv) do
    try do
      Matic.setup()

      memo =
        Loader.load_memo()
        |> Loader.rebuild_memo()
        |> Loader.write_memo()

      argv
      |> parse()
      |> decode()
      |> run(memo)
    rescue
      e in ParseError ->
        Display.error(e)
        Display.matic_help()
        System.halt(1)

      e ->
        Display.error(e)
        System.halt(1)
    else
      :ok -> System.halt(0)
    end
  end

  ## Argument Parsing ##

  @spec parse(argv) :: parse_result
  defp parse(argv),
    do: OptionParser.parse_head(argv, @parse_options)

  ## Parse Result Decoding ##

  @spec decode(parse_result) :: commandset
  defp decode({_switches, _argv, errors}) when errors !== [] do
    # Report the first unrecognized switch
    [{switch, _value}] = Enum.take(errors, 1)
    raise ParseError, {:unrecognized_switch, switch}
  end

  defp decode({switches, argv, []}) when switches !== [] do
    switches = Enum.map(switches, fn {switch, _value} -> switch end)

    unless argv === [], do: Display.warn_extraneous_args()

    if :help in switches do
      # The --help switch takes ultimate precedence
      {"help", []}
    else
      # The foremost switch takes precedence over later switches
      [switch | _rest] = switches
      # Coerce the switch into a commandset with no args
      {Atom.to_string(switch), []}
    end
  end

  defp decode({[], argv, []}) when argv !== [] do
    # Split the remaining argv into a command and its argv
    {[name], argv} = Enum.split(argv, 1)
    {name, argv}
  end

  defp decode(_),
    do: {"help", []}

  ## Running Subcommands ##

  @spec run(commandset, memo :: map) :: :ok
  defp run({"help", []}, _memo) do
    Display.matic_help()
    :ok
  end

  defp run({"help", [plugin]}, memo) do
    if Map.has_key?(memo, plugin) do
      module = Loader.main_module(memo, plugin)
      Display.help(module, plugin)
      :ok
    else
      raise ParseError, {:unrecognized_plugin, plugin}
    end
  end

  defp run({"help", [plugin | _extraneous_args]}, memo) do
    Display.warn_extraneous_args()
    run({"help", [plugin]}, memo)
  end

  defp run({"version", []}, _memo) do
    Display.matic_version()
    :ok
  end

  defp run({"version", [plugin]}, memo) do
    if Map.has_key?(memo, plugin) do
      module = Loader.main_module(memo, plugin)
      Display.version(module)
      :ok
    else
      raise ParseError, {:unrecognized_plugin, plugin}
    end
  end

  defp run({"version", [plugin | _extraneous_args]}, memo) do
    Display.warn_extraneous_args()
    run({"version", [plugin]}, memo)
  end

  defp run({"list", []}, memo) do
    for plugin <- Map.keys(memo) do
      module = Loader.main_module(memo, plugin)
      Display.listing(module, plugin)
    end

    :ok
  end

  defp run({"list", _extraneous_args}, memo) do
    Display.warn_extraneous_args()
    run({"list", []}, memo)
  end

  defp run({plugin, args}, memo) do
    if Map.has_key?(memo, plugin) do
      module = Loader.main_module(memo, plugin)
      cwd = File.cwd!()
      apply(module, :run, [cwd, args])
      :ok
    else
      raise ParseError, {:unrecognized_plugin, plugin}
    end
  end
end
