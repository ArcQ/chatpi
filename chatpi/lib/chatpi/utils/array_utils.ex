defmodule Chatpi.ArrayUtils do
  @moduledoc """
  utilities for arrays 
  """
  # add an item into an array if it it is not already in  it
  def add_if_unique(existing_items \\ [], new_item) do
    if Enum.any?(existing_items, &(&1.user_id == new_item.user_id)) do
      Enum.map(existing_items, fn existing_item ->
        if existing_item.user_id == new_item.user_id do
          new_item
        else
          existing_item
        end
      end)
    else
      [new_item | existing_items]
    end
  end
end
