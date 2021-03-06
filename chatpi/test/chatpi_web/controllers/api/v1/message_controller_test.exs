defmodule ChatpiWeb.MessageControllerTest do
  @moduledoc false

  import Mock
  import Chatpi.FixtureConstants
  use ChatpiWeb.ConnCase

  use Chatpi.Fixtures, [:organization, :user, :chat, :message]

  setup_with_mocks([
    {Chatpi.Auth.Token, [],
     [
       verify_and_validate: fn auth_token ->
         case auth_token do
           "authorized_bearer" ->
             {:ok,
              %{
                "username" => "arcq",
                "sub" => auth_key_c()
              }}

           _ ->
             {:error, "unauthed"}
         end
       end
     ]},
    {Kaffe.Producer, [], [produce_sync: fn _key, _event -> "" end]}
  ]) do
    :ok
  end

  describe "index" do
    test "lists all messages before query", %{conn: conn} do
      {:ok, _user, chat, message, _organization} = message_fixture()

      result =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> get(
          Routes.message_path(conn, :index, chat.id,
            before:
              message.inserted_at
              |> NaiveDateTime.add(100, :second)
              |> NaiveDateTime.to_iso8601()
          )
        )
        |> json_response(200)
        |> Map.get("messages")
        |> List.first()

      assert result["id"] == message.id
      assert result["text"] == message.text
      assert result["user_auth_key"] == message.user_auth_key
    end

    test "lists all messages after query", %{conn: conn} do
      {:ok, _user, chat, message, _organization} = message_fixture()

      result =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> get(Routes.message_path(conn, :index, chat.id, after: "2020-09-12T05:29:57"))
        |> json_response(200)
        |> Map.get("messages")

      assert result |> length == 1

      first_result = result |> List.first()

      assert first_result["id"] == message.id
      assert first_result["text"] == message.text
      assert first_result["user_auth_key"] == message.user_auth_key
    end
  end
end
