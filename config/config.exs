# Copyright (c) 2021 Brandon Zimmerman
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import Config

config :elixir,
  ansi_enabled: true

log_level =
  case config_env() do
    :prod -> :none
    :test -> :info
    :dev -> :debug
  end

config :logger,
  compile_time_purge_matching: [
    [level_lower_than: log_level]
  ]

config :matic,
  main_dir: "~/.matic",
  checksum_method: :md5,
  description: "Commandline plugin loader",
  help_text: """
  Usage: matic <subcommand> [args...]
         matic <plugin> [args...]

  Matic is a plugin loader. It allows you to write custom plugins (small, self-contained, CLI-oriented apps) in the Elixir language and run them from anywhere on the commandline.

  To view a listing of currently-installed plugins, use "matic list".

  For detailed directions on writing or installing a plugin, please see https://github.com/zimmydev/matic#readme

  Subcommands:

      help              View this help screen
      help [plugin]     View the help screen for a particular plugin
      version           Prints the version of matic
      version [plugin]  Prints the version of a particular plugin
      list              View a listing of installed plugins
  """
