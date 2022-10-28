defmodule HTTPClient.Behaviour do
  @moduledoc false

  @typep headers :: list()
  @typep options :: list()
  @typep payload :: binary()
  @typep reason :: atom()
  @typep request :: map()
  @typep response :: binary()
  @typep url :: binary()

  @callback get(url(), headers(), options()) ::
              {:ok, response()} | {:error, reason()}

  @callback ping(url()) ::
              :ok | {:error, :not_found} | {:error, :ping_failure}

  @callback post(url(), payload(), headers(), options()) ::
              {:ok, response()} | {:error, reason()}

  @callback request(request()) ::
              {:ok, response()} | {:error, reason()}

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end

end
