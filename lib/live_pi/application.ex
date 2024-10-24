defmodule LivePi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LivePiWeb.Telemetry,
      # LivePi.Repo,
      {DNSCluster, query: Application.get_env(:live_pi, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LivePi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LivePi.Finch},
      # Start a worker by calling: LivePi.Worker.start_link(arg)
      # {LivePi.Worker, arg},
      # Start to serve requests, typically the last entry
      LivePiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LivePi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LivePiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
