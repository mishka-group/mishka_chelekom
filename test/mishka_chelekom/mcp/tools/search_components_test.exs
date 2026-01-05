defmodule MishkaChelekom.MCP.Tools.SearchComponentsTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Tools.SearchComponents
  alias Anubis.Server.Frame

  describe "component metadata" do
    test "input_schema/0 returns a valid JSON schema" do
      schema = SearchComponents.input_schema()

      assert schema["type"] == "object"
      assert is_map(schema["properties"])
      assert "query" in schema["required"]
    end
  end

  describe "execute/2 - direct name search" do
    test "finds components by exact name" do
      frame = %Frame{}
      params = %{query: "button"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      names = Enum.map(data["results"], & &1["name"])
      assert "button" in names
    end

    test "finds components by partial name" do
      frame = %Frame{}
      params = %{query: "field"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      names = Enum.map(data["results"], & &1["name"])

      assert "input_field" in names
      assert "text_field" in names
      assert "email_field" in names
    end
  end

  describe "execute/2 - category search" do
    test "finds components in form category" do
      frame = %Frame{}
      params = %{query: "form"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      names = Enum.map(data["results"], & &1["name"])

      assert "button" in names
      assert "checkbox_field" in names
      assert "input_field" in names
    end

    test "finds components in navigation category" do
      frame = %Frame{}
      params = %{query: "navigation"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      names = Enum.map(data["results"], & &1["name"])

      assert "navbar" in names
      assert "menu" in names
      assert "tabs" in names
    end

    test "finds components in feedback category" do
      frame = %Frame{}
      params = %{query: "feedback"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      names = Enum.map(data["results"], & &1["name"])

      assert "alert" in names
      assert "toast" in names
      assert "modal" in names
    end
  end

  describe "execute/2 - keyword search" do
    test "finds date-related components" do
      frame = %Frame{}
      params = %{query: "date"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      names = Enum.map(data["results"], & &1["name"])
      assert "date_time_field" in names
    end

    test "finds notification-related components" do
      frame = %Frame{}
      params = %{query: "notification"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      names = Enum.map(data["results"], & &1["name"])

      assert "toast" in names
      assert "alert" in names
    end

    test "finds dialog-related components" do
      frame = %Frame{}
      params = %{query: "dialog"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      names = Enum.map(data["results"], & &1["name"])

      assert "modal" in names
      assert "drawer" in names
    end

    test "finds loading-related components" do
      frame = %Frame{}
      params = %{query: "loading"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      names = Enum.map(data["results"], & &1["name"])

      assert "spinner" in names
      assert "skeleton" in names
      assert "progress" in names
    end
  end

  describe "execute/2 - result format" do
    test "results include required fields" do
      frame = %Frame{}
      params = %{query: "button"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      [result | _] = data["results"]

      assert Map.has_key?(result, "name")
      assert Map.has_key?(result, "category")
      assert Map.has_key?(result, "generator")
      assert Map.has_key?(result, "docs")
    end

    test "includes total count in response" do
      frame = %Frame{}
      params = %{query: "field"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      assert is_integer(data["total"])
      assert data["total"] == length(data["results"])
    end

    test "includes helpful tip in response" do
      frame = %Frame{}
      params = %{query: "button"}

      {:reply, response, _frame} = SearchComponents.execute(params, frame)

      [content | _] = response.content
      data = Jason.decode!(content["text"])

      assert is_binary(data["tip"])
      assert String.contains?(data["tip"], "get_component_info")
    end
  end

  describe "execute/2 - case insensitivity" do
    test "search is case insensitive" do
      frame = %Frame{}

      {:reply, response1, _} = SearchComponents.execute(%{query: "BUTTON"}, frame)
      {:reply, response2, _} = SearchComponents.execute(%{query: "button"}, frame)
      {:reply, response3, _} = SearchComponents.execute(%{query: "Button"}, frame)

      [content1 | _] = response1.content
      [content2 | _] = response2.content
      [content3 | _] = response3.content

      data1 = Jason.decode!(content1["text"])
      data2 = Jason.decode!(content2["text"])
      data3 = Jason.decode!(content3["text"])

      assert data1["total"] == data2["total"]
      assert data2["total"] == data3["total"]
    end
  end
end
