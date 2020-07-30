defmodule Chatpi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @doc false
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Chatpi.Repo,
      # Start the endpoint when the application starts
      ChatpiWeb.Endpoint,
      # Starts a worker by calling: Chatpi.Worker.start_link(arg)
      # {Chatpi.Worker, arg},

      ChatpiWeb.Presence,
      {Chatpi.Auth.FetchStrategy, time_interval: 20_000}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatpi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChatpiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
