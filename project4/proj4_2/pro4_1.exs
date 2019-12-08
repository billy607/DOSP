
		{:ok, spid} = GenServer.start_link(Engine,[:hello])
		{:ok, cpid} = GenServer.start_link(Client,[spid])
		IO.inspect(cpid)
		Client.register(cpid,"lzq","a")
		Client.register(cpid,"lzq","a")
		:timer.sleep(10)
