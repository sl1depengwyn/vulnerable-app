defmodule HelloWeb.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table("users", primary_key: false) do
      add(:nickname, :string, primary_key: true)
      add(:posts_counter, :integer)
    end
  end
end
