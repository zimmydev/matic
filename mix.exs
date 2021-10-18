# Copyright (c) 2021 Brandon Zimmerman
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

defmodule Matic.MixProject do
  use Mix.Project

  def project do
    [
      app: :matic,
      version: "0.1.0",
      elixir: "~> 1.11",
      deps: deps(),
      aliases: aliases(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.5", only: ~w[dev test]a, runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      build: "escript.build",
      install: ["escript.build", "escript.install --force escript/matic"],
      uninstall: "escript.uninstall --force matic",
      check: ["dialyzer", "credo"]
    ]
  end

  defp escript do
    [
      main_module: Matic.CLI,
      path: "escript/matic"
    ]
  end
end
