defmodule ChatpiWeb.UserControllerTest do
  @moduledoc false

  import Mock
  import Chatpi.FixtureConstants
  use ChatpiWeb.ConnCase

  use Chatpi.Fixtures, [:organization, :user]

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
    test "lists all users before query", %{conn: conn} do
      result =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> get(Routes.user_path(conn, :index))
        |> json_response(200)
        |> Map.get("users")

      assert length(result) == 3
    end
  end

  describe "add_push_token" do
    test "creates push token", %{conn: conn} do
      {:ok, _organization, _user} = user_fixture()

      result =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> patch(Routes.push_token_path(conn, :add_push_token),
          type: "expo",
          token: "test_token",
          device_id: "device_id"
        )
        |> json_response(200)
        |> Map.get("push_tokens")
        |> List.first()
        |> Map.get("token")

      assert result == "test_token"
    end
  end
end
