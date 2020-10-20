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

  describe "create user" do
    test "creates user when valid", %{conn: conn} do
      {:ok, user} = user_fixture()

      result =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> post(Routes.chat_path(conn, :create), %{users: [user.id], name: "test fam"})
        |> json_response(200)

      assert %{
               "chat" => %{
                 "id" => id,
                 "inserted_at" => inserted_at,
                 "members" => [
                   %{
                     "auth_key" => "892130df-f45b-46b3-b766-2101db28ea62",
                     "id" => user_id,
                     "username" => "some name"
                   }
                 ],
                 "name" => "test fam"
               }
             } = result

      result2 =
        conn
        |> get(Routes.chat_path(conn, :show, id))
        |> json_response(200)

      assert result = result2
    end

    # test "400 when invalid", %{conn: conn} do
    #   conn =
    #     result =
    #     conn
    #     |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
    #     |> post(Routes.chat_path(conn, :create), %{})
    #     |> json_response(400)

    #   assert %{} = result
    # end
  end
end
