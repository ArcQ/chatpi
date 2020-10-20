defmodule ChatpiWeb.ErrorView do
  use ChatpiWeb, :view

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def render("500.json", %{conn: conn}) do
    %{errors: %{code: "500_SERVER_ERROR", detail: conn.assigns.reason.description}}
  end
end
