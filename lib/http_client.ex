defmodule HTTPClient do
  @moduledoc """
  Wrapper for a HTTP library.
  """
  use HTTPClient.Behaviour

  @default_opts [
    follow_redirect: true,
    max_redirect: 3,
    recv_timeout: 5_000,
    timeout: 5_000,
  ]
  @http_adapter Application.compile_env(:http_client, :http_adapter, HTTPoison)

  @doc """
  Performs a GET request on the given URL.

  ## Examples

      iex> HTTPClient.get("https://www.example.com")
      {:ok, _content}

  """
  @impl HTTPClient.Behaviour

  def get(url, headers, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)

    case @http_adapter.get(url, headers, opts) do
      {:ok, data} -> format_data(data)
      {:error, %{reason: {:max_redirect_overflow, {:ok, 302, headers, _settings}}}} ->
        {:error, %{body: "", headers: to_map(headers), status: 302}}
      {:error, error} ->
        {:error, HTTPClient.Error.from(error)}
    end
  end

  @doc """
  Pings the requested resource, return :ok, or an :error.

  ## Examples

      iex> HTTPClient.ping("https://www.example.com")
      :ok

      iex> HTTPClient.ping("https://www.this-does-not-exist.com)
      {:error, :not_found}

  """
  @impl HTTPClient.Behaviour

  def ping(url) do
    System.cmd("curl", [
      "-s",                   # silent
      "-o", "/dev/null",      # output to null
      "-I",                   # show document info only (headers)
      "-L",                   # follow redirects
      "-w", "\%{http_code}",  # format output to only return the http status code
      url
    ])
    |> case do
      {"200", 0} -> :ok
      {"404", 0} -> {:error, :not_found}
      _other     -> {:error, :ping_failure}
    end
  end

  @doc """
  Performs a POST request on the given URL and payload.

  ## Examples

      iex> HTTPClient.post("https://www.example.com", "", [], [])
      {:ok, _content}

  """
  @impl HTTPClient.Behaviour

  def post(url, payload, headers, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)

    case @http_adapter.post(url, payload, headers, opts) do
      {:ok, data} -> format_data(data)
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end

  @doc """
  Executes a given request.

  ## Examples

      iex> HTTPClient.request(%{method: :get, url: "http://www.example.com"})
      {:ok, _content}

  """
  @impl HTTPClient.Behaviour

  def request(%{method: method, url: url} = request) do
    request = %HTTPoison.Request{
      body: Map.get(request, :body, ""),
      headers: Map.get(request, :headers, []),
      method: method,
      options: Keyword.merge(@default_opts, Map.get(request, :options, [])),
      url: url,
    }

    case @http_adapter.request(request) do
      {:ok, data} -> format_data(data)
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end

  ##
  # Private
  ##

  defp format_data(%{status_code: 403}), do: {:error, :unauthorized}
  defp format_data(%{status_code: 404}), do: {:error, :not_found}
  defp format_data(%{body: body, headers: headers, status_code: status}) do
    {:ok, %{body: body, headers: to_map(headers), status: status}}
  end

  defp to_map(list), do: Enum.into(list, %{})

end
