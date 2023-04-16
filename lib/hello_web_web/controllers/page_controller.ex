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
    {time, _} = "date" |> System.cmd([], env: [{"TZ", timezone}])

    render(conn, :time, time: time |> to_string())
  end

  def time(conn, _params) do
    render(conn, :time, time: nil)
  end

  def create_message(conn, %{"text" => text, "nickname" => nickname}) do
    Repo.insert_all("users", [%{nickname: nickname, posts_counter: 1}],
      conflict_target: [:nickname],
      on_conflict:
        from(
          user in "users",
          update: [
            set: [
              posts_counter: user.posts_counter + 1
            ]
          ]
        )
    )

    Repo.insert_all("posts", [
      %{
        text: text,
        nickname: nickname,
        inserted_at: DateTime.now!("Etc/UTC"),
        updated_at: DateTime.now!("Etc/UTC")
      }
    ])

    conn
    |> redirect(to: "/forum")
  end
end
