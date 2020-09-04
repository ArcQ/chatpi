defmodule ChatpiWeb.Api.V1.FileController do
  use ChatpiWeb, :controller

  alias Chatpi.Uploads
  alias Chatpi.Uploads.File

  action_fallback(ChatpiWeb.Api.V1.FallbackController)

  def create(conn, %{"file" => file_params}) do
    chat = Chatpi.Chats.get_chat(file_params["chat_id"])

    user = Chatpi.Users.get_user_by_token!(file_params["user_token"])

    {:ok, message} =
      Chatpi.Messages.create_message(%{
        user_id: user.id,
        chat_id: chat.id,
        message: file_params["file"].filename
      })

    file_params = Map.merge(file_params, %{"message_id" => message.id})

    with {:ok, %File{} = file} <- Uploads.create_file(file_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.file_path(conn, :show, file))
      |> render("show.json", file: file)
    end
  end

  def show(conn, %{"id" => id}) do
    file = Uploads.get_file!(id)
    render(conn, "show.json", file: file)
  end
end
