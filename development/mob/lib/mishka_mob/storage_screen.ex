defmodule MishkaMob.StorageScreen do
  use Mob.Screen

  def mount(_params, _session, socket) do
    {:ok, Mob.Socket.assign(socket, status: "idle", files: [])}
  end

  def render(assigns) do
    tap_write = {self(), :write}
    tap_list = {self(), :list}
    tap_delete = {self(), :delete}

    ~MOB"""
    <Scroll background={:background}>
      <Column background={:background} padding={:space_lg}>
        <Text text="Storage" text_size={:lg} text_color={:on_surface} padding={:space_sm} />
        <Text text={"Status: #{assigns.status}"} text_size={:sm} text_color={:primary} padding={4} />
        <Spacer size={16} />
        <Button
          text="Write test file"
          background={:primary}
          text_color={:on_primary}
          padding={:space_md}
          fill_width={true}
          on_tap={tap_write}
        />
        <Spacer size={12} />
        <Button
          text="List documents"
          background={:surface}
          text_color={:on_surface}
          padding={:space_md}
          fill_width={true}
          on_tap={tap_list}
        />
        <Spacer size={12} />
        <Button
          text="Delete test file"
          background={:surface}
          text_color={:on_surface}
          padding={:space_md}
          fill_width={true}
          on_tap={tap_delete}
        />
        <Spacer size={20} />
        {file_list(assigns.files)}
      </Column>
    </Scroll>
    """
  end

  defp file_list([]) do
    ~MOB(<Text text="No files listed yet" text_size={:sm} text_color={:muted} padding={4} />)
  end

  defp file_list(files) do
    items =
      Enum.map(files, fn f ->
        %{
          type: :text,
          props: %{text: Path.basename(f), text_size: :sm, text_color: :on_surface, padding: 4},
          children: []
        }
      end)

    %{type: :column, props: %{}, children: items}
  end

  def handle_info({:tap, :write}, socket) do
    path = Path.join(Mob.Storage.dir(:documents), "mishka_mob_test.txt")

    case Mob.Storage.write(path, "MishkaMob storage test\n#{DateTime.utc_now()}") do
      {:ok, _} -> {:noreply, Mob.Socket.assign(socket, status: "written: #{Path.basename(path)}")}
      {:error, posix} -> {:noreply, Mob.Socket.assign(socket, status: "write error: #{posix}")}
    end
  end

  def handle_info({:tap, :list}, socket) do
    case Mob.Storage.list(:documents) do
      {:ok, files} ->
        {:noreply, Mob.Socket.assign(socket, files: files, status: "#{length(files)} file(s)")}

      {:error, posix} ->
        {:noreply, Mob.Socket.assign(socket, status: "list error: #{posix}")}
    end
  end

  def handle_info({:tap, :delete}, socket) do
    path = Path.join(Mob.Storage.dir(:documents), "mishka_mob_test.txt")

    case Mob.Storage.delete(path) do
      :ok -> {:noreply, Mob.Socket.assign(socket, status: "deleted")}
      {:error, posix} -> {:noreply, Mob.Socket.assign(socket, status: "delete error: #{posix}")}
    end
  end

  def handle_info(_msg, socket), do: {:noreply, socket}
end
