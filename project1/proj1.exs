defmodule Wait do
    def waitSignal do
		receive do
			{:finish} -> true
    	end
    end
end

args = System.argv()
n1 = String.to_integer(Enum.at(args,0))
n2 = String.to_integer(Enum.at(args,1))
pid = self()
if n1<10 do
	if n2<10 do
		send self(),{:finish}
	else 
		n1 = 10
		if rem((n2-n1+1),1000) != 0 do
			Boss.start_link(div((n2-n1+1),1000)+1,pid,n1,n2)
		else
			Boss.start_link(div((n2-n1+1),1000),pid,n1,n2)
		end
    end
else
	if rem((n2-n1+1),1000) != 0 do
		Boss.start_link(div((n2-n1+1),1000)+1,pid,n1,n2)
	else
		Boss.start_link(div((n2-n1+1),1000),pid,n1,n2)
    end
end
Wait.waitSignal
