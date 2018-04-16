defmodule HelayClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :helay_client,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {HelayClient.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:grpc, github: "tony612/grpc-elixir"},
      {:poison, "~> 3.0"},
      {:tesla, "~> 0.10.0"},
      {:confex, "~> 3.3.1"},
      {:porcelain, "~> 2.0"},
      {:cowboy, "~> 2.2.0"},
      {:plug, "~> 1.5"},
      {:http_receiver, in_umbrella: true}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true},
    ]
  end
end
