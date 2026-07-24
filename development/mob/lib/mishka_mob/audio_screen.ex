defmodule MishkaMob.AudioScreen do
  use Mob.Screen

  @test_audio "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"

  def mount(_params, _session, socket) do
    {:ok, Mob.Socket.assign(socket, status: "idle", volume: 1.0)}
  end

  def render(assigns) do
    tap_play = {self(), :play}
    tap_stop = {self(), :stop}
    on_vol   = {self(), :volume}
    vol_pct  = round(assigns.volume * 100)
    ~MOB"""
    <Scroll background={:background}>
      <Column background={:background} padding={:space_lg}>
        <Text text="Audio Playback" text_size={:lg} text_color={:on_surface} padding={:space_sm} />
        <Text text={"Status: #{assigns.status}"} text_size={:sm} text_color={:primary} padding={4} />
        <Spacer size={20} />
        <Button text="Play" background={:primary} text_color={:on_primary} padding={:space_md} fill_width={true} on_tap={tap_play} />
        <Spacer size={12} />
        <Button text="Stop" background={:surface} text_color={:on_surface} padding={:space_md} fill_width={true} on_tap={tap_stop} />
        <Spacer size={20} />
        <Text text={"App Volume: #{vol_pct}%"} text_size={:sm} text_color={:on_surface} padding={4} />
        <Slider min={0.0} max={1.0} value={assigns.volume} on_change={on_vol} />
      </Column>
    </Scroll>
    """
  end

  def handle_info({:tap, :play}, socket) do
    socket = Mob.Audio.play(socket, @test_audio, volume: socket.assigns.volume)
    {:noreply, Mob.Socket.assign(socket, status: "playing")}
  end

  def handle_info({:tap, :stop}, socket) do
    socket = Mob.Audio.stop_playback(socket)
    {:noreply, Mob.Socket.assign(socket, status: "stopped")}
  end

  def handle_info({:change, :volume, volume}, socket) do
    socket = Mob.Audio.set_volume(socket, volume)
    {:noreply, Mob.Socket.assign(socket, volume: volume)}
  end

  def handle_info({:audio, :playback_finished, _}, socket) do
    {:noreply, Mob.Socket.assign(socket, status: "finished")}
  end

  def handle_info({:audio, :playback_error, %{reason: reason}}, socket) do
    {:noreply, Mob.Socket.assign(socket, status: "error: #{reason}")}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}
end
