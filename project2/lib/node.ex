##########################################genserver Node
defmodule Node do
	use GenServer
	def init(list) do
		{:ok,list}
	end
	def start_link(neighbor,s,w,times) do
		GenServer.start_link(__MODULE__,[neighbor,s,w,times])
	end
	def update(pid,newneighbor) do
		GenServer.cast(pid, {:update, newneighbor})
	end
	def receive(pid,message) do
		GenServer.cast(pid, {:receive,pid, message})
	end
	def receive_sum(pid,s,w) do
		GenServer.cast(pid, {:receive_sum,s,w})
	end
	def send(pid) do
		GenServer.cast(pid, {:send})
	end
	def send_sum(pid) do
		GenServer.cast(pid, {:send_sum})
	end
	def update_minus(pid,newneighbor) do
		GenServer.cast(pid, {:update_minus,newneighbor})
	end
	
	
	def handle_cast({:update,newneighbor},list) do
		neighbor=hd(list)++newneighbor
		list=List.replace_at(list,0,neighbor)
		{:noreply, list}
	end	
	def handle_cast({:update_minus,newneighbor},list) do
		neighbor=hd(list)--[newneighbor] 
		list=List.replace_at(list,0,neighbor)
		if Enum.empty?(neighbor) do 
			IO.inspect(self(), label: "done_no_neighbor")
			Process.exit(self(),:normal) 
		end
		{:noreply, list}
	end
	def handle_cast({:send},list) do
		des=Enum.random(hd(list))
		Node.receive(des,"hello")
		:timer.sleep(10)
		Node.send(self())
		{:noreply, list}
	end
	def handle_cast({:send_sum}, list) do
		s=Enum.at(list,1)
		w=Enum.at(list,2)
		list=List.replace_at(list,1,s/2)
		list=List.replace_at(list,2,w/2)
		des=Enum.random(hd(list))
		Node.receive_sum(des,s/2,w/2)
		:timer.sleep(20)
		#Node.send_sum(self())
		{:noreply, list}
	end
	def handle_cast({:receive, pid, message},list) do
		send :main,{:finish}
		IO.inspect(self(),label: "receive")
		last=List.last(list)
		last=last+1
		list=List.replace_at(list,3,last)
		if message=="hello" do
			if last==10 do
				IO.inspect(self(), label: "done_heard_10")
				Enum.each(hd(list),fn(x)->Node.update_minus(x,self())end)
				Process.exit(pid,:normal)
			end
		end
		Node.send(pid)
		{:noreply, list}
	end
	def handle_cast({:receive_sum,s,w},[neighbor,olds,oldw,last]) do
		ns=s+olds
		nw=w+oldw
		IO.inspect([self(),s,w,s/w],label: "pid,s,w,s/w")
		minus=Kernel.abs(ns/nw-olds/oldw)
		last=
			if minus<=:math.pow(10,-10) do  
				if last==2 do
					IO.inspect(self(), label: "done with no change")
					Enum.each(neighbor,fn(x)->Node.update_minus(x,self())end)
					send :main,{:finish}
					Process.exit(self(),:normal)
				end
				last+1
			else
				0
			end
		Node.send_sum(self())
		{:noreply, [neighbor,ns,nw,last]}
	end
end