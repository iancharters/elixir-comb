defmodule Comb.Mixfile do
  use Mix.Project

  def project do
    [
      app: :comb,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:httpotion],
      extra_applications: [:logger, :httpotion]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 0.13"},
      {:httpotion, "~> 3.0.2"}
    ]
  end
end
