defmodule HTTPClient.Error do
  @moduledoc """
  Wrap client error in HTTPClient.Error struct.
  """
  @type t :: %__MODULE__{id: reference() | nil, reason: any()}

  defexception [:id, :reason]

  @doc """
  Pass an error, return a HTTPClient.Error.
  """
  def from(%HTTPoison.Error{id: id, reason: reason}),
    do: %__MODULE__{id: id, reason: reason}

  @doc """
  Returns the error message in a readable format.
  """
  def message(%__MODULE__{reason: reason, id: nil}),
    do: inspect(reason)
  def message(%__MODULE__{reason: reason, id: id}),
    do: "[Reference: #{id}] - #{inspect(reason)}"

end
