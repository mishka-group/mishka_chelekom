defmodule MishkaChelekom.CmsBundle.NpmTest do
  @moduledoc """
  The pinned package tree a CMS hook ships with, resolved against a registry this test writes.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.CmsBundle.Npm

  # A registry document: `versions` of `name`, each `{version, manifest}`; every version gets an
  # integrity hash unless its manifest says `dist: %{}`.
  defp registry(packages) do
    docs =
      Map.new(packages, fn {name, versions} ->
        {name,
         %{
           "name" => name,
           "versions" =>
             Map.new(versions, fn {version, manifest} ->
               {version,
                Map.merge(
                  %{"dist" => %{"integrity" => "sha512-#{name}@#{version}"}},
                  manifest
                )}
             end)
         }}
      end)

    fn name ->
      case Map.fetch(docs, name) do
        {:ok, doc} -> {:ok, doc}
        :error -> {:error, "#{name}: HTTP 404"}
      end
    end
  end

  defp tree({:ok, entries}), do: Map.new(entries, &{&1["path"], &1["version"]})

  describe "satisfies?/2" do
    test "reads the ranges npm writes" do
      for {version, range} <- [
            {"1.4.0", "^1.2.3"},
            {"0.2.9", "^0.2.3"},
            {"0.0.3", "^0.0.3"},
            {"1.2.9", "~1.2.3"},
            {"1.9.0", "~1"},
            {"1.2.3", "1.2.3"},
            {"1.2.7", "1.2.x"},
            {"1.9.9", "1"},
            {"2.0.0", ">=1.2 <3"},
            {"1.3.0", ">1.2"},
            {"1.2.5", "1.2.0 - 1.3"},
            {"3.1.0", "^1.0.0 || ^3.0.0"},
            {"5.0.0", "*"},
            {"5.0.0", ""},
            {"2.0.0-beta.2", ">=2.0.0-beta.1"}
          ] do
        assert Npm.satisfies?(version, range), "#{version} should satisfy #{range}"
      end
    end

    test "and refuses what they exclude" do
      for {version, range} <- [
            {"2.0.0", "^1.2.3"},
            {"0.3.0", "^0.2.3"},
            {"0.0.4", "^0.0.3"},
            {"1.3.0", "~1.2.3"},
            {"1.2.4", "1.2.3"},
            {"1.2.0", ">1.2"},
            {"1.4.0", "1.2.0 - 1.3"},
            {"2.5.0", "^1.0.0 || ^3.0.0"},
            {"1.0.0", "not a range"}
          ] do
        refute Npm.satisfies?(version, range), "#{version} should not satisfy #{range}"
      end
    end

    # npm's rule: a pre-release is taken only by a range that names one of the same version.
    test "a pre-release only by a range that names one" do
      refute Npm.satisfies?("1.5.0-beta.1", "^1.0.0")
      refute Npm.satisfies?("2.0.0-beta.1", "^1.0.0")
      refute Npm.satisfies?("1.3.0-rc.1", ">1.2")
      assert Npm.satisfies?("1.5.0-beta.2", ">=1.5.0-beta.1 <2")
    end
  end

  describe "closure/2" do
    test "no pins, no packages and no request" do
      assert Npm.closure([], fn _name -> flunk("nothing to fetch") end) == {:ok, []}
    end

    test "the pins and everything they depend on, flat, with their integrity" do
      fetch =
        registry(%{
          "chart" => [{"6.1.0", %{"dependencies" => %{"zr" => "6.1.0", "tslib" => "2.3.0"}}}],
          "zr" => [{"6.1.0", %{"dependencies" => %{"tslib" => "2.3.0"}}}],
          "tslib" => [{"2.3.0", %{}}, {"2.8.0", %{}}]
        })

      assert {:ok, entries} = Npm.closure([%{name: "chart", version: "6.1.0"}], fetch)

      assert entries == [
               %{
                 "name" => "chart",
                 "version" => "6.1.0",
                 "path" => "node_modules/chart",
                 "integrity" => "sha512-chart@6.1.0"
               },
               %{
                 "name" => "tslib",
                 "version" => "2.3.0",
                 "path" => "node_modules/tslib",
                 "integrity" => "sha512-tslib@2.3.0"
               },
               %{
                 "name" => "zr",
                 "version" => "6.1.0",
                 "path" => "node_modules/zr",
                 "integrity" => "sha512-zr@6.1.0"
               }
             ]
    end

    test "a range takes the newest version that satisfies it" do
      fetch =
        registry(%{
          "app" => [{"1.0.0", %{"dependencies" => %{"lib" => "^1.2.0"}}}],
          "lib" => [{"1.2.0", %{}}, {"1.9.4", %{}}, {"2.0.0", %{}}, {"1.10.0-beta.1", %{}}]
        })

      assert tree(Npm.closure([%{name: "app", version: "1.0.0"}], fetch)) == %{
               "node_modules/app" => "1.0.0",
               "node_modules/lib" => "1.9.4"
             }
    end

    test "a version the top holds is nested under the package that cannot use it" do
      fetch =
        registry(%{
          "a" => [{"1.0.0", %{"dependencies" => %{"lib" => "^1.0.0"}}}],
          "b" => [{"1.0.0", %{"dependencies" => %{"lib" => "^2.0.0"}}}],
          "lib" => [{"1.5.0", %{}}, {"2.1.0", %{}}]
        })

      assert tree(
               Npm.closure(
                 [%{name: "a", version: "1.0.0"}, %{name: "b", version: "1.0.0"}],
                 fetch
               )
             ) == %{
               "node_modules/a" => "1.0.0",
               "node_modules/b" => "1.0.0",
               "node_modules/lib" => "1.5.0",
               "node_modules/b/node_modules/lib" => "2.1.0"
             }
    end

    # THE EDITOR'S CASE. The kit takes its extensions at `^3.28.0`, the newest extension wants a newer
    # core than the pinned one, and a second core breaks the editor at runtime: the versions that
    # accept the pinned core are taken instead, and the extension's own peer is placed before it.
    test "versions whose peers fit the pins, so nothing is duplicated" do
      peers = fn version -> %{"peerDependencies" => %{"core" => "^#{version}"}} end

      fetch =
        registry(%{
          "core" => [{"3.28.0", %{}}, {"3.31.4", %{}}],
          "kit" => [
            {"3.28.0", %{"dependencies" => %{"ext-bullet" => "^3.28.0", "ext-list" => "^3.28.0"}}}
          ],
          "ext-list" => [{"3.28.0", peers.("3.28.0")}, {"3.31.4", peers.("3.31.4")}],
          "ext-bullet" => [
            {"3.28.0", %{"peerDependencies" => %{"ext-list" => "^3.28.0"}}},
            {"3.31.4", %{"peerDependencies" => %{"ext-list" => "^3.31.4"}}}
          ]
        })

      assert tree(
               Npm.closure(
                 [%{name: "core", version: "3.28.0"}, %{name: "kit", version: "3.28.0"}],
                 fetch
               )
             ) == %{
               "node_modules/core" => "3.28.0",
               "node_modules/kit" => "3.28.0",
               "node_modules/ext-list" => "3.28.0",
               "node_modules/ext-bullet" => "3.28.0"
             }
    end

    test "optional dependencies and optional peers are left out" do
      fetch =
        registry(%{
          "app" => [
            {"1.0.0",
             %{
               "dependencies" => %{"native" => "1.0.0", "lib" => "1.0.0"},
               "optionalDependencies" => %{"native" => "1.0.0"},
               "peerDependencies" => %{"react" => "^18"},
               "peerDependenciesMeta" => %{"react" => %{"optional" => true}}
             }}
          ],
          "lib" => [{"1.0.0", %{}}]
        })

      assert tree(Npm.closure([%{name: "app", version: "1.0.0"}], fetch)) == %{
               "node_modules/app" => "1.0.0",
               "node_modules/lib" => "1.0.0"
             }
    end

    test "a scoped package goes under its scope" do
      fetch = registry(%{"@tiptap/core" => [{"3.28.0", %{}}]})

      assert tree(Npm.closure([%{name: "@tiptap/core", version: "3.28.0"}], fetch)) == %{
               "node_modules/@tiptap/core" => "3.28.0"
             }
    end

    test "says what it could not resolve" do
      no_integrity = registry(%{"app" => [{"1.0.0", %{"dist" => %{}}}]})

      assert {:error, "app@1.0.0 has no sha512 integrity hash in the registry"} =
               Npm.closure([%{name: "app", version: "1.0.0"}], no_integrity)

      missing = registry(%{"app" => [{"1.0.0", %{}}]})

      assert {:error, "app@9.9.9 is not in the registry"} =
               Npm.closure([%{name: "app", version: "9.9.9"}], missing)

      no_match =
        registry(%{
          "app" => [{"1.0.0", %{"dependencies" => %{"lib" => "^5.0.0"}}}],
          "lib" => [{"1.0.0", %{}}]
        })

      assert {:error, "no version of lib satisfies ^5.0.0"} =
               Npm.closure([%{name: "app", version: "1.0.0"}], no_match)

      assert {:error, "gone: HTTP 404"} =
               Npm.closure([%{name: "gone", version: "1.0.0"}], missing)
    end
  end
end
