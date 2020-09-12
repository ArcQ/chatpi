defmodule ChatpiWeb.ErrorView do
  use ChatpiWeb, :view

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack} = err) do
    IO.puts("An error occurred, the error was:")
    IO.puts(err)

    conn
  end
end
