defmodule ToTheWonder.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ToTheWonderWeb.Telemetry,
      ToTheWonder.Repo,
      {DNSCluster, query: Application.get_env(:to_the_wonder, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ToTheWonder.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ToTheWonder.Finch},
      # Start a worker by calling: ToTheWonder.Worker.start_link(arg)
      # {ToTheWonder.Worker, arg},
      # Start to serve requests, typically the last entry
      ToTheWonderWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ToTheWonder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ToTheWonderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
