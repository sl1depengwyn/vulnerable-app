defmodule HelloWebWeb.PageController do
  use HelloWebWeb, :controller

  import Ecto.Query
  alias HelloWeb.Repo

  def home(conn, _params) do
    render(conn, :home)
  end

  def forum(conn, _params) do
    posts =
      Repo.all(
        from(
          post in "posts",
          select: %{text: post.text, nickname: post.nickname, date: post.inserted_at}
        )
      )

      users =
        Repo.all(
          from(
            users in "users",
            select: %{counter: users.posts_counter, nickname: users.nickname}
          )
        )

    data = %{text: "", nickname: ""}
    types = %{text: :string, nickname: :string}
    params = %{}

    changeset =
      {data, types}
      |> Ecto.Changeset.cast(params, Map.keys(types))

    conn
    |> render(:forum, posts: posts, changeset: changeset, users: users)
  end

  def time(conn, %{"timezone" => timezone}) do
    time = "TZ=#{timezone} date" |> String.to_charlist() |> :os.cmd() |> to_string()
    render(conn, :time, time: time)
  end

  def time(conn, _params) do
    render(conn, :time, time: nil)
  end

  def create_message(conn, %{"text" => text, "nickname" => nickname}) do
    result =
        Repo.query(
          """
          WITH
            U AS (INSERT INTO users as u (nickname, posts_counter) values ('#{nickname}', '1') ON CONFLICT (nickname) DO UPDATE SET posts_counter = u.posts_counter + 1),
            P AS (INSERT INTO posts (text, nickname, inserted_at, updated_at) values ('#{text}', '#{nickname}','#{DateTime.now!("Etc/UTC")}','#{DateTime.now!("Etc/UTC")}'))
          SELECT true
          """
        )
    conn
    |> put_flash(:error, inspect(result))
    |> redirect(to: "/forum")
  end
end
