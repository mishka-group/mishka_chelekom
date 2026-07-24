defmodule MishkaMob.App do
  @moduledoc "Application entry point for MishkaMob."

  use Mob.App

  @impl Mob.App
  def navigation(_platform) do
    stack(:main, root: MishkaMob.HomeScreen)
  end

  @impl Mob.App
  def on_start do
    # Configure BEAM's DNS path so Req / Finch / Mint / `gen_tcp:connect/3`
    # with a hostname work on iOS without per-host setup. Flips the lookup
    # chain from the iOS-broken `:native` (inet_gethost port program) path
    # to `[:file, :dns]` and seeds Google + Cloudflare as fallback
    # nameservers. Override with `nameservers:` if you need to (corporate
    # resolver, Quad9, etc.) — see `Mob.DNS.configure_pure_beam/1`.
    #
    # For hosts that need Apple's resolver (VPN-pushed DNS, mDNS,
    # captive portals, search-domain expansion) call `Mob.DNS.resolve/1`
    # for those specific hostnames here too. Both paths compose.
    Mob.DNS.configure_pure_beam()

    {:ok, _} = Application.ensure_all_started(:ecto_sqlite3)
    {:ok, _} = MishkaMob.Repo.start_link()
    Ecto.Migrator.with_repo(MishkaMob.Repo, fn repo ->
      Ecto.Migrator.run(repo, migrations_dir(), :up, all: true)
    end)

    # Register pure-Elixir UI composites (custom `<Tag>` widgets that expand to
    # built-in nodes). No native code, no mob.exs entry.
    Mob.Composite.register(:mishka_drawer, {MishkaMob.Components.MishkaDrawer, :expand})

    # Register components into the gallery (see MishkaMob.Showcase). One line per
    # component — the generic gallery/component screens do the rest.
    MishkaMob.Showcase.register(MishkaMob.Showcase.Components.Drawer)

    Mob.Screen.start_root(MishkaMob.HomeScreen)
    Mob.Dist.ensure_started(node: :"mishka_mob_android@127.0.0.1", cookie: :mob_secret)
  end

  # Returns the path to the migrations directory for the current environment.
  #
  # WHY NOT Application.app_dir/2?
  #
  # Application.app_dir(app, "priv/repo/migrations") calls :code.priv_dir(app)
  # under the hood. That works in a normal `mix run` dev environment where the
  # app lives in $OTP_ROOT/lib/APP-VERSION/ebin/.
  #
  # On Android and iOS, Mob deploys .beam files to a flat -pa directory with no
  # versioned lib structure, so :code.priv_dir/1 returns {error, bad_name}.
  # Ecto.Migrator.run/3 silently finds zero migrations and logs "Migrations
  # already up" — tables are never created and any query against them crashes
  # the screen GenServer, making the screen appear frozen.
  #
  # The fix: mob_beam.c/mob_beam.m set MOB_BEAMS_DIR=beams_dir before erl_start.
  # The deployer pushes priv/ into beams_dir/priv/ and runs chmod -R 755 on it
  # (mkdir-as-root creates system:system drwxrwx--x dirs that the app process
  # can traverse but not list, breaking Path.wildcard). Here we read MOB_BEAMS_DIR
  # and pass the explicit path to Ecto.Migrator.run/4.
  defp migrations_dir do
    case System.get_env("MOB_BEAMS_DIR") do
      nil       -> Application.app_dir(:mishka_mob, "priv/repo/migrations")
      beams_dir -> Path.join([beams_dir, "priv", "repo", "migrations"])
    end
  end
end
