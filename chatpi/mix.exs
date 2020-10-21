defmodule Chatpi.MixProject do
  use Mix.Project

  def project do
    [
      app: :chatpi,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      # Docs
      name: "Chatpi",
      source_url: "https://github.com/arcq/chatpi",
      homepage_url: "https://chatpi.com",
      docs: [
        # The main page in the docs
        main: "Chatpi",
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Chatpi.Application, []},
      extra_applications: [:logger, :runtime_tools, :timex]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.3"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0-rc"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:uuid, "~> 1.1.8"},

      # Authentication
      {:bcrypt_elixir, "~> 1.0"},
      {:guardian, "~> 1.1"},
      {:comeonin, "~> 4.0"},
      {:joken, "~> 2.2"},
      {:joken_jwks, "~> 1.3.1"},

      # Use arc and arc_ecto for upload and process images with imagemagick
      {:arc, "~> 0.11.0"},
      {:arc_ecto, "~> 0.11.1"},

      # Markdown parsing & HTML sanitize
      {:phoenix_html_sanitizer, "~> 1.0.0"},
      {:earmark, "~> 1.3.0"},

      # if you're using a s3 bucket for production
      # install ex_aws and ex_aws_s3, then configure it in config/prod.exs
      {:ex_aws, "~> 2.0", only: [:prod]},
      {:ex_aws_s3, "~> 2.0", only: [:prod]},
      # {:hackney, "~> 1.9"},
      {:hackney, "~> 1.15.2"},
      {:sweet_xml, "~> 0.6.5"},
      {:timex, "~> 3.6.2"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:kaffe, "~> 1.0"},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      check: [
        "format --check-formatted",
        "credo"
      ],
      check_ci: [
        # "check",
        "ecto.reset",
        "test"
      ]
    ]
  end
end
