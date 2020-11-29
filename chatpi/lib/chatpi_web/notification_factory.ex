defmodule ChatpiWeb.NotificationFactory do
  @moduledoc false

  @doc false
  def create_notification("MESSAGE", token, title, body) do
    format_message(%{
      to: "ExponentPushToken[" <> token <> "]",
      title: "To " <> title,
      body: body
    })
  end

  defp format_message(message) do
    message
    |> Map.replace!("title", &(&1 |> String.slice(0..29)))
    |> Map.replace!("body", &(&1 |> String.slice(0..29)))
  end
end
