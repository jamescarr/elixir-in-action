defmodule Todo.MixProject do
  use Mix.Project

  def project do
    [
      app: :todo,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: extra_applications(Mix.env()),
      mod: {Todo.Application, []}
    ]
  end

  defp extra_applications(:prod), do: [:logger]
  defp extra_applications(_), do: [:logger, :wx, :runtime_tools, :observer]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:poolboy, "~> 1.5"}
    ]
  end
end
