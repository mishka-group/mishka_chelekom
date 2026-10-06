defmodule MishkaChelekom.CmsBundle.Npm do
  @moduledoc """
  The npm packages a CMS hook needs, as the complete pinned tree a CMS downloads.

  A component names its packages in its `.exs` with exact versions —
  `npm: [%{name: "echarts", version: "6.1.0"}]`. A CMS runs no package manager and resolves nothing,
  so `closure/2` resolves the whole tree here, at export, into entries that each say where the
  package goes, its exact version and the registry's integrity hash:

      [
        %{"name" => "echarts", "version" => "6.1.0", "path" => "node_modules/echarts", "integrity" => "sha512-…"},
        %{"name" => "tslib", "version" => "2.3.0", "path" => "node_modules/tslib", "integrity" => "sha512-…"},
        %{"name" => "zrender", "version" => "6.0.0", "path" => "node_modules/zrender", "integrity" => "sha512-…"}
      ]

  The CMS downloads, verifies and unpacks exactly that list, and the same list always gives the
  same files.

  Placement is npm's: a package goes at the top of `node_modules/` unless another version already
  holds the name, and then under the package that needs it. Peer dependencies resolve like
  dependencies, so the pinned packages answer them; optional dependencies and optional peers are left
  out. A range takes the newest version that satisfies it, and never a pre-release unless the range
  names one.
  """

  @registry "https://registry.npmjs.org"

  @type entry :: %{String.t() => String.t()}
  @type fetch :: (String.t() -> {:ok, map()} | {:error, String.t()})

  @doc """
  The tree `pins` need, sorted by path. `fetch` answers a package's registry document — the default
  asks #{@registry}; a test passes its own.
  """
  @spec closure([map()], fetch()) :: {:ok, [entry()]} | {:error, String.t()}
  def closure(pins, fetch \\ &fetch/1)

  def closure([], _fetch), do: {:ok, []}

  def closure(pins, fetch) do
    state = %{placed: %{}, docs: %{}, fetch: fetch}

    with {:ok, state, queue} <- place_pins(pins, state),
         {:ok, state} <- walk(queue, state) do
      {:ok,
       state.placed
       |> Enum.map(fn {path, pkg} ->
         %{
           "name" => pkg.name,
           "version" => pkg.version,
           "path" => path,
           "integrity" => pkg.integrity
         }
       end)
       |> Enum.sort_by(& &1["path"])}
    end
  end

  defp place_pins(pins, state) do
    Enum.reduce_while(pins, {:ok, state, []}, fn pin, {:ok, state, queue} ->
      name = to_string(pin[:name] || pin["name"])
      version = to_string(pin[:version] || pin["version"])
      path = "node_modules/" <> name

      with {:ok, doc, state} <- doc(name, state),
           {:ok, pkg} <- package(name, version, doc) do
        {:cont, {:ok, put_in(state.placed[path], pkg), queue ++ [path]}}
      else
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp walk([], state), do: {:ok, state}

  defp walk([path | queue], state) do
    {deps, state} = peers_first(path, state.placed[path].deps, state)

    result =
      Enum.reduce_while(deps, {:ok, state, queue}, fn {dep, range}, {:ok, state, queue} ->
        case resolve(path, dep, range, state) do
          {:ok, state, nil} -> {:cont, {:ok, state, queue}}
          {:ok, state, placed} -> {:cont, {:ok, state, queue ++ [placed]}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)

    case result do
      {:ok, state, queue} -> walk(queue, state)
      error -> error
    end
  end

  # A SIBLING'S PEER IS PLACED BEFORE THE SIBLING. `extension-bullet-list` names `extension-list` as a
  # peer; taken alphabetically it is placed first, finds no `extension-list` to fit and takes the
  # newest — which then wants a newer `@tiptap/core` than the pinned one. Placing what the others name
  # as peers first lets each of them choose the version that fits it.
  defp peers_first(path, deps, state) do
    {peer_names, state} =
      Enum.reduce(deps, {MapSet.new(), state}, fn {dep, range}, {names, state} ->
        with true <- unsatisfied?(path, dep, range, state),
             {:ok, doc, state} <- doc(dep, state),
             {_v, _parsed, manifest} <- newest_candidate(doc, range) do
          {MapSet.union(names, MapSet.new(Map.keys(manifest["peerDependencies"] || %{}))), state}
        else
          _not_needed -> {names, state}
        end
      end)

    {Enum.sort_by(deps, fn {name, _range} -> {not MapSet.member?(peer_names, name), name} end),
     state}
  end

  defp unsatisfied?(path, dep, range, state) do
    case Enum.find(lookup_chain(path, dep), &Map.has_key?(state.placed, &1)) do
      nil -> true
      nearest -> not satisfies?(state.placed[nearest].version, range)
    end
  end

  # WHAT NODE WOULD FIND from `path`: the package's own `node_modules`, each ancestor's, then the top.
  # The nearest one is the one that loads, so it is the only one that has to satisfy the range.
  defp resolve(path, dep, range, state) do
    nearest = Enum.find(lookup_chain(path, dep), &Map.has_key?(state.placed, &1))

    cond do
      nearest && satisfies?(state.placed[nearest].version, range) ->
        {:ok, state, nil}

      nearest == nested(path, dep) ->
        {:error,
         "#{dep}@#{range}, needed by #{state.placed[path].name}, conflicts with " <>
           "#{dep}@#{state.placed[nearest].version} already at #{nearest}"}

      true ->
        # Under the package that needs it while a version it cannot use is nearer; at the top
        # otherwise, where nothing holds the name yet.
        target = if nearest, do: nested(path, dep), else: "node_modules/" <> dep

        with {:ok, doc, state} <- doc(dep, state),
             {:ok, version} <- newest(doc, range, dep, &peers_fit?(&1, target, state)),
             {:ok, pkg} <- package(dep, version, doc) do
          {:ok, put_in(state.placed[target], pkg), target}
        end
    end
  end

  defp nested(path, dep), do: "#{path}/node_modules/#{dep}"

  defp lookup_chain(path, dep) do
    segments =
      path |> String.replace_prefix("node_modules/", "") |> String.split("/node_modules/")

    owners =
      for n <- length(segments)..1//-1,
          do: "node_modules/" <> Enum.join(Enum.take(segments, n), "/node_modules/")

    Enum.map(owners, &nested(&1, dep)) ++ ["node_modules/" <> dep]
  end

  defp doc(name, %{docs: docs} = state) do
    case Map.fetch(docs, name) do
      {:ok, doc} ->
        {:ok, doc, state}

      :error ->
        with {:ok, doc} <- state.fetch.(name),
             do: {:ok, doc, put_in(state.docs[name], doc)}
    end
  end

  defp package(name, version, doc) do
    case get_in(doc, ["versions", version]) do
      %{"dist" => %{"integrity" => "sha512-" <> _ = integrity}} = manifest ->
        {:ok, %{name: name, version: version, integrity: integrity, deps: deps(manifest)}}

      %{} ->
        {:error, "#{name}@#{version} has no sha512 integrity hash in the registry"}

      nil ->
        {:error, "#{name}@#{version} is not in the registry"}
    end
  end

  # Dependencies and required peers, sorted so the same inputs always place the same tree.
  defp deps(manifest) do
    optional = Map.keys(manifest["optionalDependencies"] || %{})

    optional_peers =
      for {name, %{"optional" => true}} <- manifest["peerDependenciesMeta"] || %{}, do: name

    (manifest["dependencies"] || %{})
    |> Map.merge(manifest["peerDependencies"] || %{})
    |> Map.drop(optional ++ optional_peers)
    |> Enum.sort()
  end

  # THE NEWEST VERSION WHOSE PEERS FIT WHAT IS ALREADY PLACED, else the newest. `@tiptap/starter-kit`
  # 3.28.0 takes its extensions at `^3.28.0`; the newest of those wants `@tiptap/core ^3.31.4`, so
  # taking it would place a second `@tiptap/core` — and a second ProseMirror — under every extension,
  # which fails at runtime. The newest one that accepts the pinned 3.28.0 keeps a single copy.
  defp newest(doc, range, name, fits?) do
    candidates = candidates(doc, range)

    case Enum.find(candidates, fn {_v, _parsed, manifest} -> fits?.(manifest) end) ||
           List.first(candidates) do
      {v, _parsed, _manifest} -> {:ok, v}
      nil -> {:error, "no version of #{name} satisfies #{range}"}
    end
  end

  defp newest_candidate(doc, range), do: doc |> candidates(range) |> List.first()

  defp candidates(doc, range) do
    (doc["versions"] || %{})
    |> Enum.flat_map(fn {v, manifest} ->
      case Version.parse(v) do
        {:ok, parsed} -> if satisfies?(parsed, range), do: [{v, parsed, manifest}], else: []
        :error -> []
      end
    end)
    |> Enum.sort_by(fn {_v, parsed, _manifest} -> parsed end, {:desc, Version})
  end

  defp peers_fit?(manifest, target, state) do
    optional =
      for {name, %{"optional" => true}} <- manifest["peerDependenciesMeta"] || %{}, do: name

    (manifest["peerDependencies"] || %{})
    |> Map.drop(optional)
    |> Enum.all?(fn {peer, range} ->
      case Enum.find(lookup_chain(target, peer), &Map.has_key?(state.placed, &1)) do
        nil -> true
        nearest -> satisfies?(state.placed[nearest].version, range)
      end
    end)
  end

  @doc """
  Whether `version` satisfies the npm range `range`: `^`, `~`, `x`/`*` wildcards, partial versions,
  `>= <= > < =` comparators, hyphen ranges and `||`.
  """
  @spec satisfies?(String.t() | Version.t(), String.t()) :: boolean()
  def satisfies?(version, range) when is_binary(version) do
    case Version.parse(version) do
      {:ok, parsed} -> satisfies?(parsed, range)
      :error -> false
    end
  end

  def satisfies?(%Version{} = version, range) do
    range
    |> String.split("||")
    |> Enum.any?(fn alternative ->
      comparators = alternative |> String.trim() |> comparators()

      comparators != :invalid and Enum.all?(comparators, &compare?(version, &1)) and
        prerelease_allowed?(version, comparators)
    end)
  end

  # A PRE-RELEASE SATISFIES ONLY A RANGE THAT NAMES ONE of the same major.minor.patch, as npm rules:
  # `^1.0.0` never takes `2.0.0-beta`.
  defp prerelease_allowed?(%Version{pre: []}, _comparators), do: true

  defp prerelease_allowed?(version, comparators) do
    Enum.any?(comparators, fn {op, bound} ->
      op != :ceiling and bound.pre != [] and
        {bound.major, bound.minor, bound.patch} == {version.major, version.minor, version.patch}
    end)
  end

  defp compare?(version, {op, bound}) do
    order = Version.compare(version, bound)

    case op do
      :>= -> order in [:gt, :eq]
      :> -> order == :gt
      :<= -> order in [:lt, :eq]
      :< -> order == :lt
      :ceiling -> order == :lt
      := -> order == :eq
    end
  end

  defp comparators(""), do: []

  defp comparators(alternative) do
    case Regex.run(~r/^(\S+)\s+-\s+(\S+)$/, alternative) do
      [_, from, to] ->
        with {:ok, low} <- partial(from), {:ok, high} <- partial(to) do
          [{:>=, floor_of(low)} | upper_inclusive(high)]
        else
          _ -> :invalid
        end

      nil ->
        alternative
        |> String.replace(~r/(>=|<=|>|<|=)\s+/, "\\1")
        |> String.split(~r/\s+/, trim: true)
        |> Enum.reduce_while([], fn token, acc ->
          case comparator(token) do
            :invalid -> {:halt, :invalid}
            list -> {:cont, acc ++ list}
          end
        end)
    end
  end

  defp comparator(token) when token in ["*", "x", "X", "latest"], do: []

  defp comparator("^" <> rest) do
    with {:ok, p} <- partial(rest) do
      upper =
        cond do
          p.major > 0 or p.minor == nil -> {p.major + 1, 0, 0}
          p.minor > 0 or p.patch == nil -> {0, p.minor + 1, 0}
          true -> {0, 0, p.patch + 1}
        end

      [{:>=, floor_of(p)}, {:ceiling, ceiling(upper)}]
    else
      _ -> :invalid
    end
  end

  defp comparator("~" <> rest) do
    with {:ok, p} <- partial(rest) do
      upper = if p.minor == nil, do: {p.major + 1, 0, 0}, else: {p.major, p.minor + 1, 0}
      [{:>=, floor_of(p)}, {:ceiling, ceiling(upper)}]
    else
      _ -> :invalid
    end
  end

  defp comparator(">=" <> rest), do: bound(rest, fn p -> [{:>=, floor_of(p)}] end)
  defp comparator("<=" <> rest), do: bound(rest, &upper_inclusive/1)
  defp comparator(">" <> rest), do: bound(rest, &greater_than/1)
  defp comparator("<" <> rest), do: bound(rest, fn p -> [{:<, floor_of(p)}] end)
  defp comparator("=" <> rest), do: comparator(rest)

  defp comparator(token) do
    bound(token, fn
      %{patch: nil} = p -> [{:>=, floor_of(p)}, {:ceiling, ceiling(next_of(p))}]
      p -> [{:=, floor_of(p)}]
    end)
  end

  defp bound(text, fun) do
    case partial(text) do
      {:ok, p} -> fun.(p)
      :error -> :invalid
    end
  end

  defp greater_than(%{patch: nil} = p) do
    {major, minor, patch} = next_of(p)
    [{:>=, %Version{major: major, minor: minor, patch: patch, pre: []}}]
  end

  defp greater_than(p), do: [{:>, floor_of(p)}]

  defp upper_inclusive(%{patch: nil} = p), do: [{:ceiling, ceiling(next_of(p))}]
  defp upper_inclusive(p), do: [{:<=, floor_of(p)}]

  defp next_of(%{minor: nil, major: major}), do: {major + 1, 0, 0}
  defp next_of(%{patch: nil, major: major, minor: minor}), do: {major, minor + 1, 0}

  defp floor_of(%{full: %Version{} = full}), do: full

  defp floor_of(p),
    do: %Version{major: p.major, minor: p.minor || 0, patch: p.patch || 0, pre: []}

  # The lowest version past a bound, pre-releases included: `<2.0.0-0`, as npm writes it. Compared as
  # `<`, and never read as a range naming a pre-release.
  defp ceiling({major, minor, patch}),
    do: %Version{major: major, minor: minor, patch: patch, pre: [0]}

  # `1`, `1.2`, `1.2.x`, `1.2.3`, `1.2.3-beta.1`, with a leading `v` tolerated.
  defp partial(text) do
    text = text |> String.trim() |> String.trim_leading("v")

    case Version.parse(text) do
      {:ok, full} ->
        {:ok, %{major: full.major, minor: full.minor, patch: full.patch, full: full}}

      :error ->
        case String.split(text, ".") do
          [major] -> numbers([major, nil, nil])
          [major, minor] -> numbers([major, minor, nil])
          [major, minor, patch] -> numbers([major, minor, patch])
          _ -> :error
        end
    end
  end

  defp numbers(parts) do
    parts
    |> Enum.map(fn
      nil -> nil
      part when part in ["x", "X", "*"] -> nil
      part -> Integer.parse(part)
    end)
    |> case do
      [{major, ""}, minor, patch] -> wildcards(major, minor, patch)
      _ -> :error
    end
  end

  defp wildcards(major, nil, _patch), do: {:ok, %{major: major, minor: nil, patch: nil}}
  defp wildcards(major, {minor, ""}, nil), do: {:ok, %{major: major, minor: minor, patch: nil}}

  defp wildcards(major, {minor, ""}, {patch, ""}),
    do: {:ok, %{major: major, minor: minor, patch: patch}}

  defp wildcards(_major, _minor, _patch), do: :error

  @doc false
  @spec fetch(String.t()) :: {:ok, map()} | {:error, String.t()}
  def fetch(name) do
    {:ok, _apps} = Application.ensure_all_started([:inets, :ssl])
    url = String.to_charlist("#{@registry}/#{String.replace(name, "/", "%2f")}")

    ssl = [
      verify: :verify_peer,
      cacerts: :public_key.cacerts_get(),
      customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
    ]

    case :httpc.request(
           :get,
           {url, [{~c"accept", ~c"application/json"}]},
           [ssl: ssl, timeout: 60_000],
           body_format: :binary
         ) do
      {:ok, {{_http, 200, _reason}, _headers, body}} -> decode(name, body)
      {:ok, {{_http, status, _reason}, _headers, _body}} -> {:error, "#{name}: HTTP #{status}"}
      {:error, reason} -> {:error, "#{name}: #{inspect(reason)}"}
    end
  end

  defp decode(name, body) do
    case Jason.decode(body) do
      {:ok, %{} = doc} -> {:ok, doc}
      _not_a_document -> {:error, "#{name}: the registry did not answer with a package document"}
    end
  end
end
