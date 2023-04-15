defmodule HelloWeb.Repo do
  use Ecto.Repo,
    otp_app: :hello_web,
    adapter: Ecto.Adapters.Postgres
end
