# Copyright (c) 2021 Brandon Zimmerman
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

defmodule Matic.Display do
  @moduledoc """
  This module is concerned with any output to the terminal.
  """

  @matic_description Application.compile_env!(:matic, :description)
  @matic_help_text Application.compile_env!(:matic, :help_text)

  ## Warning/Error Output ##

  @spec warn_extraneous_args() :: :ok
  def warn_extraneous_args,
    do: print_warning("extraneous arguments have been ignored")

  @spec error(Exception.t()) :: :ok
  def error(%File.Error{action: action, path: path, reason: reason}) do
    reason = :file.format_error(reason)
    message = "encountered an error while trying to #{action} at #{inspect(path)}: #{reason}"
    print_error(message)
  end

  def error(%CompileError{description: description, file: file, line: line}) do
    location = "#{file}:#{line}"
    message = "encountered an error while compiling #{inspect(location)}: #{description}"
    print_error(message)
  end

  def error(exception) when is_exception(exception),
    do: print_error(exception[:message] || "enountered an unknown error")

  ## Warning/Error Output Helpers ##

  @spec print_warning(String.t()) :: :ok
  defp print_warning(message) do
    [:yellow, "Warning: ", message]
    |> IO.ANSI.format()
    |> puts_stderr()
  end

  @spec print_error(String.t()) :: :ok
  defp print_error(message) do
    [:red, "Error: ", message]
    |> IO.ANSI.format()
    |> puts_stderr()
  end

  @spec puts_stderr(IO.chardata() | String.t()) :: :ok
  defp puts_stderr(output),
    do: IO.puts(:stderr, output)

  ## Info Screens ##

  @spec matic_version() :: :ok
  def matic_version,
    do: IO.puts(Matic.version())

  @spec version(module) :: :ok
  def version(module) when is_atom(module),
    do: IO.puts(module.version())

  @spec matic_help() :: :ok
  def matic_help,
    do:
      do_help(
        "matic",
        @matic_description,
        Matic.version(),
        @matic_help_text
      )

  @spec help(module, String.t()) :: :ok
  def help(module, plugin)
      when is_atom(module) and is_binary(plugin),
      do:
        do_help(
          "matic #{plugin}",
          module.description(),
          module.version(),
          module.help()
        )

  @spec listing(module, String.t()) :: :ok
  def listing(module, plugin)
      when is_atom(module) and is_binary(plugin),
      do:
        do_listing(
          plugin,
          module.description(),
          module.version()
        )

  ## Info Screens Helpers ##

  @spec do_help(String.t(), String.t(), String.t(), String.t()) :: :ok
  defp do_help(plugin, description, version, body),
    do: IO.puts("#{plugin} - #{description} [version #{version}]\n\n#{body}")

  @spec do_listing(String.t(), String.t(), String.t()) :: :ok
  defp do_listing(plugin, description, version),
    do: IO.puts("#{plugin}\t# #{description} [#{version}]")
end
