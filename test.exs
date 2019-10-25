defmodule Pro3 do
	def main(args) do
		maxHop=0
		Process.register(self(),:main)
		numNodes=Enum.at(args,0)
		numRequsts=Enum.at(args,1)
		objMap=%{}
		guid=0
		neighbor=%{}
		neighborMap=[["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"],
					["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"],
					["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"],
					["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"]]
		{:ok, pid}=TNode.start_link("NULL",guid,objectMap,neighbor,neighborMap,true)
		list=list++[pid]
		list=list++
			Enum.map(1..numNodes-1,fn(x)->
				{:ok, pid}=TNode.start_link("NULL",guid,objectMap,neighbor,neighborMap,false)
				pid
			end)
		Enum.map(1..numRequsts,fn(y)-> 
			Enum.map(list, fn(x)->
				nid=Enum.random(list--[x])
				TNode.routeToNode(x,nid,1,x,numHop)
			end)		
		end)
		waitSignal(numNodes*numRequsts,maxHop)
		
	end
	
	def waitSignal(n,maxHop) when n==0 do
		:timer.sleep(10)
		IO.puts("maxHop")
	end
	def waitSignal(n,maxHop) do
		receive do
			{:compareNumHop,numHop}->
				maxHop=
					if maxHop<numHop do
						maxHop=numHop
					end
				waitSignal(n-1,maxHop)
		after
			3000->
				IO.inspect(n, label: "Unreached node number")
				waitSignal(0)
		end
	end
end