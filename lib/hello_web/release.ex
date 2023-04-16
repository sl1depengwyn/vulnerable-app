defmodule HelloWeb.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :hello_web

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    # If using Ecto 3.0 or higher
    :ecto_sql
  ]

  def create_and_migrate do
    start_services()

    create()
    migrate()

    stop_services()
  end

  defp start_services do
    IO.puts("Starting dependencies..")
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo(s) for app
    IO.puts("Starting repos..")

    # Switch pool_size to 2 for ecto > 3.0
    Enum.each([HelloWeb.Repo], & &1.start_link(pool_size: 2))
  end

  def create() do
    case HelloWeb.Repo.__adapter__().storage_up(HelloWeb.Repo.config()) do
      :ok -> :ok
      {:error, :already_up} -> :ok
      {:error, term} -> {:error, term}
    end
  end

  defp stop_services do
    IO.puts("Success!")
    :init.stop()
  end

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
