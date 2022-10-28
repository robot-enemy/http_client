defmodule HTTPClientTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Mox

  @data "{\"data\": \"something\"}"
  @headers []
  @opts []
  @payload %{}

  setup :verify_on_exit!

  describe "get/3" do

    test "when given a valid attributes, returns the fetched data" do
      url     = "https://www.example.com"

      expect(HTTPoisonMock, :get, fn ^url, @headers, _opts ->
        {:ok, %HTTPoison.Response{body: @data, status_code: 200}}
      end)

      assert {:ok, %{body: @data, headers: %{}, status: 200}}
                = HTTPClient.get(url, @headers, @opts)
    end

    test "when given a non-existent url, returns a not found error" do
      url = "https://www.example.com/non-existent"

      expect(HTTPoisonMock, :get, fn ^url, @headers, _opts ->
        {:ok, %HTTPoison.Response{body: "", status_code: 404}}
      end)

      assert {:error, :not_found} = HTTPClient.get(url, @headers)
    end

  end

  describe "post/4" do

    test "when given valid attributes, returns the fetched data" do
      url = "https://www.example.com"

      expect(HTTPoisonMock, :post, fn ^url, @payload, @headers, _opts ->
        {:ok, %HTTPoison.Response{body: @data, status_code: 200}}
      end)

      assert {:ok, %{body: @data, headers: %{}, status: 200}}
                = HTTPClient.post(url, @payload, @headers, @opts)
    end

    test "when given invalid attributes, returns an error" do
      url = "https://www.example.com/non-existent"

      expect(HTTPoisonMock, :post, fn ^url, @payload, @headers, _opts ->
        {:ok, %{body: "", status_code: 404}}
      end)

      assert {:error, :not_found} = HTTPClient.post(url, @payload, @headers)
    end

  end

  describe "request/1" do

    test "when given a valid request, returns the fetched data" do
      request = %{
        body: "",
        headers: [],
        method: :get,
        options: [],
        url: "https://www.example.com",
      }

      expect(HTTPoisonMock, :request, fn _request ->
        {:ok, %HTTPoison.Response{body: "test", status_code: 200}}
      end)

      assert {:ok, %{body: "test", headers: %{}, status: 200}}
               = HTTPClient.request(request)
    end

    test "when given invalid attributes, returns an error" do
      request = %{
        method: :get,
        options: [],
        url: "https://www.example.com/non-existent",
      }

      expect(HTTPoisonMock, :request, fn _request ->
        {:ok, %{body: "", status_code: 404}}
      end)

      assert {:error, :not_found} = HTTPClient.request(request)
    end

  end

end
