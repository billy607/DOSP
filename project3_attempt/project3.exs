#nNodes = String.to_integer(Enum.at(System.argv,0))
#nRequests = String.to_integer(Enum.at(System.argv,1))
map = [["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"],
["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"],
["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"],
["NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"]]
IO.inspect(self(),label: "main")
TNode.start_link("NULL","0001","0002",%{},map,true)
:timer.sleep(10)
TNode.start_link("NULL","0001","0002",%{},map,false)
:timer.sleep(100000)
receive do
    {:finish} -> true
    # code
end

