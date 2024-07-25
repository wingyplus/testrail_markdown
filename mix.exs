defmodule TestRailMarkdown.MixProject do
  use Mix.Project

  def project do
    [
      app: :testrailmd,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def escript do
    [
      main_module: TestRailMarkdown.Cli,
    ]
  end

  defp deps do
    [
      {:earmark, "~> 1.4"}
    ]
  end
end
