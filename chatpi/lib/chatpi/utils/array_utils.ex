defmodule Chatpi.ArrayUtils do
  @moduledoc """
  utilities for arrays 
  """
  # add an item into an array if it it is not already in  it
  def add_if_unique(existing_items \\ [], new_item, key) do
    if Enum.any?(existing_items, &(Map.get(&1, key) == Map.get(new_item, key))) do
      Enum.map(existing_items, fn existing_item ->
        if Map.get(existing_item, key) == Map.get(new_item, key) do
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
