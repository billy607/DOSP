defmodule Stack do
  use GenServer

  # Client

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  def hello(pid,text) do
    Stack.echo(self())
    GenServer.cast(pid, {:hi,text})
  end

  def echo(pid) do
    GenServer.cast(pid, :echo)
  end

  # Server (callbacks)

  @impl true
  def init(list) do
    {:ok,list}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end

  def handle_cast({:hi, text}, state) do
    IO.inspect(text)
    {:noreply, state}
  end

  def handle_cast(:echo, state) do
    IO.puts("ooooooooo")
    {:noreply, state}
  end
end

defmodule Sender do
  use GenServer

  # Client

  def start_link(pid) do
    GenServer.start_link(__MODULE__, pid)
  end

  @impl true
  def init(stack) do
    pid = hd(stack)
    send pid,{:finish}
    {:ok, stack}
  end
end