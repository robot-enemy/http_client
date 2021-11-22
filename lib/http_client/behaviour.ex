defmodule HTTPClient.Behaviour do
  @moduledoc false

  @typep headers :: list()
  @typep options :: list()
  @typep payload :: binary()
  @typep response :: binary()
  @typep url :: binary()

  @callback get(url(), headers(), options()) ::
              {:ok, response()} | {:error, atom()}

  @callback ping(url()) ::
              :ok | {:error, :not_found} | {:error, :ping_failure}

  @callback post(url(), payload(), headers(), options()) ::
              {:ok, response()} | {:error, atom()}

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end

end
