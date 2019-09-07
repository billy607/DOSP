#{:ok,pid} = Stack.start_link(10)
#IO.inspect(Stack.next(pid))
#IO.inspect(Stack.next(pid))

defmodule Wait do
    def waitSignal do
        IO.puts("im waiting")
		receive do
			{:finish} -> IO.puts("end waits")
    	end
    end
end

mpid = self()
{:ok,pid} = Stack.start_link(5)
IO.inspect(mpid)
IO.inspect(pid)
Stack.test(pid,mpid)
Wait.waitSignal

