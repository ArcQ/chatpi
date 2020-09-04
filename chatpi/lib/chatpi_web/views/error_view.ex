defmodule ChatpiWeb.ErrorView do
  use ChatpiWeb, :view

  def handle_errors(conn, %{kind: kind, reason: reason, stack: stack} = err) do
    IO.inspect "An error occurred, the error was:"
    IO.inspect err

    conn
  end
end
