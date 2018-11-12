defmodule Base2.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nocursor/base2"

  def project do
    [
      app: :base2,
      version: @version,
      elixir: ">= 1.7.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "Elixir library for encoding and decoding binaries in Base2.",
      package: package(),

      # Docs
      name: "Base2",
      source_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
    ]
  end

  defp package do
    [
      maintainers: [
        "nocursor",
      ],
      licenses: ["MIT"],
      links: %{github: @source_url},
      files: ~w(lib NEWS.md LICENSE.md mix.exs README.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extra_section: "PAGES",
      extras: extras(),
    ]
  end

  defp extras do
    [
      "README.md",
    ]
  end

  defp deps do
    [
      {:benchee, "~> 0.13.2", only: [:dev]},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.13", only: [:dev], runtime: false},
    ]
  end
end
