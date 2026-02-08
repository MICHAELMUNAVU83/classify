defmodule Classify.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ClassifyWeb.Telemetry,
      Classify.Repo,
      {DNSCluster, query: Application.get_env(:classify, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Classify.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Classify.Finch},
      # Start a worker by calling: Classify.Worker.start_link(arg)
      # {Classify.Worker, arg},
      # Start to serve requests, typically the last entry
      ClassifyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Classify.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ClassifyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
