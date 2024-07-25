defmodule TestRailMarkdown.Cli do
  @moduledoc """
  CLI application for TestRailMarkdown
  """

  def main([md_path]) do
    File.read!(md_path)
    |> TestRailMarkdown.export()
    |> IO.puts()
  end
end
