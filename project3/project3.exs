nNodes = String.to_integer(Enum.at(System.argv,0))
nRequests = String.to_integer(Enum.at(System.argv,1))
TNode.test(nNodes,nRequests)