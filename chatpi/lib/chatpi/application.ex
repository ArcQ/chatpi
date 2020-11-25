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
      {Phoenix.PubSub, name: Chatpi.PubSub},
      ChatpiWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatpi.Supervisor]

    if Application.get_env(:chatpi, :env) == :test do
      Supervisor.start_link(
        children,
        opts
      )
    else
      Supervisor.start_link(
        children ++
          [
            {Chatpi.Auth.FetchStrategy, time_interval: 60_000},
            %{
              id: Kaffe.GroupMemberSupervisor,
              start: {Kaffe.GroupMemberSupervisor, :start_link, []},
              type: :supervisor
            },
            Supervisor.Spec.worker(Chatpi.UnreadMessagesWorker, [0])
          ],
        opts
      )
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChatpiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
