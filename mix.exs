defmodule TypeClassPlayground.MixProject do
  use Mix.Project

  def project do
    [
      app: :type_class_playground,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:currying, "~> 1.0.3"},
      {:typed_struct, "~> 0.1.4"}
    ]
  end
end
