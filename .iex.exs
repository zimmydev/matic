# If there is an iex global config in the home folder, import that:
if File.exists?(Path.expand("~/.iex.exs")), do: import_file("~/.iex.exs")

# Aliases go here
alias Matic.{CLI, Display, Filesystem, Loader, Plugin}

defmodule Helpers do
  def test_memoization do
    memo = Loader.load_memo()
    memo = Loader.rebuild_memo(memo)
    Loader.write_memo(memo)

    Enum.each(memo, fn {_name, {_hash, compilation}} ->
      Enum.each(compilation, fn {module, _bytecode} ->
        IO.write("#{inspect(module)}: ")

        try do
          description = apply(module, :description, [])
          IO.puts("#{inspect(description)}")
        rescue
          _ -> IO.puts("[FAILED]")
        end
      end)
    end)
  end
end
