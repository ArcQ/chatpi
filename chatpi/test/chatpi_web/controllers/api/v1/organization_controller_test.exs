defmodule ChatpiWeb.OrganizationControllerTest do
  use ChatpiWeb.ConnCase

  alias Chatpi.Organizations
  alias Chatpi.Organizations.Organization
  import Mock
  import Chatpi.FixtureConstants

  @create_attrs %{
    api_key: "some api_key",
    api_secret_hash: "some api_secret_hash",
    name: "some name"
  }
  @update_attrs %{
    api_key: "some updated api_key",
    api_secret_hash: "some updated api_secret_hash",
    name: "some updated name"
  }
  # @invalid_attrs %{api_key: nil, api_secret_hash: nil, name: nil}

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

  def fixture(:organization) do
    {:ok, organization} = Organizations.create_organization(@create_attrs)
    organization
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all organizations", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> get(Routes.organization_path(conn, :index))

      assert json_response(conn, 200)["data"] |> length == 1
    end
  end

  describe "create organization" do
    test "renders organization when data is valid", %{conn: conn} do
      post_res =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> post(Routes.organization_path(conn, :create), organization: @create_attrs)
        |> json_response(201)

      assert %{"id" => id} = post_res["data"]

      get_res =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> get(Routes.organization_path(conn, :show, id))
        |> json_response(200)

      assert %{
               "id" => id,
               "api_key" => "some api_key",
               "api_secret_hash" => "some api_secret_hash",
               "name" => "some name"
             } = get_res["data"]
    end

    # test "renders errors when data is invalid", %{conn: conn} do
    #   conn =
    #     conn
    #     |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
    #     |> post(Routes.organization_path(conn, :create), organization: @invalid_attrs)
    #     |> json_response(201)

    #   assert json_response(conn, 422)["errors"] != %{}
    # end
  end

  describe "update organization" do
    setup [:create_organization]

    test "renders organization when data is valid", %{
      conn: conn,
      organization: %Organization{id: id} = organization
    } do
      put_res =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> put(Routes.organization_path(conn, :update, organization),
          organization: @update_attrs
        )

      assert %{"id" => ^id} = json_response(put_res, 200)["data"]

      get_res =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> get(Routes.organization_path(conn, :show, id))

      assert %{
               "id" => id,
               "api_key" => "some updated api_key",
               "api_secret_hash" => "some updated api_secret_hash",
               "name" => "some updated name"
             } = json_response(get_res, 200)["data"]
    end

    # test "renders errors when data is invalid", %{conn: conn, organization: organization} do
    #   conn =
    #     conn
    #     |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
    #     |> put(Routes.organization_path(conn, :update, organization), organization: @invalid_attrs)

    #   assert json_response(conn, 422)["errors"] != %{}
    # end
  end

  describe "delete organization" do
    setup [:create_organization]

    test "deletes chosen organization", %{conn: conn, organization: organization} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> "authorized_bearer")
        |> delete(Routes.organization_path(conn, :delete, organization))

      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.organization_path(conn, :show, organization))
      end)
    end
  end

  defp create_organization(_) do
    organization = fixture(:organization)
    %{organization: organization}
  end
end
