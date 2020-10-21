defmodule ChatpiWeb.MessageControllerTest do
  @moduledoc false

  import Mock
  import Chatpi.FixtureConstants
  use ChatpiWeb.ConnCase

  use Chatpi.Fixtures, [:user, :chat, :message]

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
      {:ok, _user, chat, message} = message_fixture()

      result =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> get(
          Routes.message_path(conn, :index, chat.id,
            query_type: "before",
            inserted_at:
              message.inserted_at
              |> NaiveDateTime.add(10, :second)
              |> NaiveDateTime.to_string()
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
      {:ok, _user, chat, message} = message_fixture()

      result =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> get(
          Routes.message_path(conn, :index, chat.id,
            query_type: "after",
            inserted_at: "2020-09-12T05:29:57"
          )
        )
        |> json_response(200)
        |> Map.get("messages")
        |> List.first()

      assert result["id"] == message.id
      assert result["text"] == message.text
      assert result["user_auth_key"] == message.user_auth_key
    end
  end
end
