defmodule MishkaMob.WebViewScreen do
  use Mob.Screen

  def mount(_params, _session, socket) do
    {:ok, Mob.Socket.assign(socket, last_msg: nil)}
  end

  def render(assigns) do
    ~MOB"""
    <Column background={:background} fill_width={true} fill_height={true}>
      <Text text="WebView" text_size={:lg} text_color={:on_surface} padding={:space_md} />
      {status_row(assigns)}
      <WebView url="https://www.google.com" show_url={true} weight={1} />
    </Column>
    """
  end

  defp status_row(%{last_msg: nil}) do
    ~MOB(<Text text="Waiting for JS bridge event..." text_size={:sm} text_color={:muted} padding={:space_sm} />)
  end
  defp status_row(%{last_msg: msg}) do
    text = "JS->Elixir: #{inspect(msg)}"
    ~MOB(<Text text={text} text_size={:sm} text_color={:primary} padding={:space_sm} />)
  end

  def handle_info({:webview, :message, data}, socket) do
    socket = Mob.WebView.post_message(socket, %{"echo" => data})
    {:noreply, Mob.Socket.assign(socket, last_msg: data)}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}
end
