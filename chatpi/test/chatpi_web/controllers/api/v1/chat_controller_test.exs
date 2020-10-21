defmodule ChatpiWeb.ChatControllerTest do
  @moduledoc false

  import Mock
  import Chatpi.FixtureConstants
  use ChatpiWeb.ConnCase

  alias Chatpi.Chats

  use Chatpi.Fixtures, [:user, :chat]

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
    {Kaffe.Producer, [], [produce_sync: fn key, event -> "" end]}
  ]) do
    :ok
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      {:ok, _user, _chat} = chat_fixture()

      result =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> get(Routes.chat_path(conn, :index))
        |> json_response(200)

      assert %{
               "chats" => [
                 %{"id" => id, "name" => "fixture chat 1"}
               ]
             } = result
    end
  end
end
