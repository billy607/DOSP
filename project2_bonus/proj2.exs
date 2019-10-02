nNodes = String.to_integer(Enum.at(System.argv,0))
topo = Enum.at(System.argv,1)
alg = Enum.at(System.argv,2)
nFail = String.to_integer(Enum.at(System.argv,3))
if nNodes<=1 do 
	IO.puts("node number should larger than 1")
else
	Pro2.start(nNodes,topo,alg,nFail)
end
