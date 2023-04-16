defmodule Elixir.HelloWeb.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table("posts") do
      add(:text, :string)
      add(:nickname, :string)

      timestamps()
    end
  end
end
