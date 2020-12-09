defmodule TestUtils do
  @moduledoc false

  def sql_sandbox_allow_pid(process_name) do
    pid =
      Chatpi.Supervisor
      |> Supervisor.which_children()
      |> Enum.filter(&(elem(&1, 0) == process_name))
      |> List.first()
      |> elem(1)

    Ecto.Adapters.SQL.Sandbox.allow(Chatpi.Repo, self(), pid)
  end

  def forget(struct, field, cardinality \\ :one) do
    %{
      struct
      | field => %Ecto.Association.NotLoaded{
          __field__: field,
          __owner__: struct.__struct__,
          __cardinality__: cardinality
        }
    }
  end
end
