defmodule ChatpiWeb.OrganizationView do
  use ChatpiWeb, :view
  alias ChatpiWeb.OrganizationView

  def render("index.json", %{organizations: organizations}) do
    %{data: render_many(organizations, OrganizationView, "organization.json")}
  end

  def render("show.json", %{organization: organization}) do
    %{data: render_one(organization, OrganizationView, "organization.json")}
  end

  def render("organization.json", %{organization: organization}) do
    %{id: organization.id,
      name: organization.name,
      api_key: organization.api_key,
      api_secret: organization.api_secret}
  end
end
