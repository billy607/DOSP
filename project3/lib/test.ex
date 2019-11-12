defmodule Pro3 do
	def main(arg1,arg2) do
		Process.register(self(),:main)
		numNodes=arg1
		numRequsts=arg2
		if numNodes<2||numRequsts<1 do
			IO.puts("node number should larger than 1 and request number should larger than 0")
			Process.exit(self(),:normal)
		end
		neighbor=%{}
		list=[]
		neighborMap=[["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"],
					["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"],
					["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"],
					["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"]]
		{:ok, pid}=TNode.start_link("NULL",neighbor,neighborMap,true,[])
		sha1 = :crypto.hash(:sha, Kernel.inspect(pid)) |> Base.encode16
		nid = String.slice(sha1,0..3)
		#IO.inspect(nid)
		list=list++[{nid,pid}]
		list=list++
			Enum.map(1..numNodes-1,fn(_x)->
				{:ok, pid}=TNode.start_link("NULL",neighbor,neighborMap,false,[])
				sha1 = :crypto.hash(:sha, Kernel.inspect(pid)) |> Base.encode16
				nid = String.slice(sha1,0..3)
				#IO.inspect(nid)
				{nid,pid}
			end)
		map=Map.new(List.flatten(list))
		list=Map.values(map)
		Enum.map(list,fn(x)->
			TNode.update(x,map)
			receive do
				{:updatefinish}-> {:ok}
			end
		end)
		Enum.map(list,fn(x)->
			#IO.inspect(x)
			TNode.insert(x)
		end)
		Enum.map(1..numRequsts,fn(_y)-> 
			nidlist=Map.keys(map)
			Enum.map(nidlist, fn(x)->
				nid=Enum.random(nidlist--[x])
				pid=map[x]
				TNode.routeToNode(pid,nid,1,pid,0)
			end)		
		end)
		waitSignal(length(list)*numRequsts,0)
		
	end
	
	def waitSignal(n,maxHop) when n==0 do
		:timer.sleep(10)
		IO.inspect(maxHop, label: "max hop")
	end
	def waitSignal(n,maxHop) do
		receive do
			{:compareNumHop,numHop}->
				#IO.inspect(numHop)
				maxHop=
					if maxHop<numHop do
						numHop
					else
						maxHop
					end
				waitSignal(n-1,maxHop)
		after
			3000->
				IO.inspect(n, label: "Unreached node number")
				waitSignal(0,maxHop)
		end
	end
end