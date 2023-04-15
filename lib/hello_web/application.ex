defmodule HelloWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HelloWebWeb.Telemetry,
      # Start the Ecto repository
      HelloWeb.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: HelloWeb.PubSub},
      # Start Finch
      {Finch, name: HelloWeb.Finch},
      # Start the Endpoint (http/https)
      HelloWebWeb.Endpoint
      # Start a worker by calling: HelloWeb.Worker.start_link(arg)
      # {HelloWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HelloWebWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
