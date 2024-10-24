defmodule LivePiWeb.PiLive do
  use LivePiWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok, pid} = GenServer.start_link(LivePiWeb.PiStreamer, [])
      :timer.send_interval(100, self(), :update)
      {:ok, assign(socket, pi: "3.", streamer: pid)}
    else
      {:ok, assign(socket, pi: "3.", streamer: nil)}
    end
  end

  def handle_info(:update, %{assigns: %{streamer: pid}} = socket) when is_pid(pid) do
    new_digit = GenServer.call(pid, :next_digit)
    new_pi = socket.assigns.pi <> to_string(new_digit)
    {:noreply, assign(socket, pi: new_pi)}
  end

  def handle_info(:update, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <div id="pi-container">
      <%= @pi %>
    </div>
    """
  end
end

defmodule LivePiWeb.PiStreamer do
  use GenServer

  def init(_) do
    {:ok, StreamingPi.stream() |> Stream.drop(1)}
  end

  def handle_call(:next_digit, _from, stream) do
    {digit, rest} = Enum.split(stream, 1)
    {:reply, hd(digit), rest}
  end
end
