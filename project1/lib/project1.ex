defmodule Worker do
	use GenServer
	def init(bRange) do
		{:ok,bRange}
	end
	def start_link(bid,n1,n2) do
		GenServer.start_link(__MODULE__,[bid,n1,n2])
	end

	def caculate(pid) do
		GenServer.cast(pid,:caculate)
	end


    def test do
		receive do
			{:get,n1,n2,caller} ->
				:timer.sleep(500)
				IO.puts("#{n1},#{n2}")
				send caller,{:finish}
        end
    end

	def handle_cast(:caculate,bRange) do
		bid = hd(bRange)
		range = tl(bRange)
		n1=hd(range)
		n2=List.last(range)
		list = []
		res = Enum.filter(Enum.map(n1..n2,fn(x)->list ++ findFangs(x) end), &!is_nil(&1))
		Boss.print(bid,res)
		#if res != [] , do: res=Enum.map(res,fn(x)->Enum.join(x," ") end)
		{:noreply,range}		
	end

	def caRange(n1,n2) do
		list = []
		res = Enum.filter(Enum.map(n1..n2,fn(x)->list ++ findFangs(x) end), &!is_nil(&1))
		if res != [] , do: Enum.each(res,fn(x)->IO.puts(Enum.join(x," ")) end)
	end
	
	def findFangs(number) do
	list=split(number,[])
	len=length(list)
	list1=of(list)
	list1=Enum.map(list1,fn(x)->Enum.chunk_every(x,div(len,2)) end)
	list1=Enum.map(list1,fn(x)->
		Enum.map(x,fn(y)->(connect(y,1,0))
	end)
	end)
#	list2=[]
#	len1=length(list1)
#	list1=duplicate(list1,list2,len1)
#	IO.inspect(list1)
#	length(list1)
	isVamp(list1,number)
end

def isVamp(list,number) do
	list1=Enum.map(list,fn(x)->
		if List.first(x)*List.last(x) == number&&(rem(List.first(x),10)!=0||rem(List.last(x),10)!=0) do x end
	end)
	list1=Enum.filter(list1, & !is_nil(&1))
	list1=duplicate(Enum.uniq(list1),[])
	if !Enum.empty?(list1) do
		List.flatten([number]++List.flatten(list1))
	end
end

#查找重复并删除
def duplicate(list1,list2) when list1==[] do
	list2=ifnil(list2)
	list2
end

def duplicate(list1,list2) do
	x=hd(list1)
	list2=list2++(Enum.map(list1--[x],fn(y)->
			if List.first(x)==List.last(y)&&List.last(x)==List.first(y) do x end end))
	duplicate(list1--[hd(list1)],list2)
	
end
#删除空值

def ifnil(list) do
    answer=Enum.any?(list,fn(x)->x==nil end)
	if answer==true do
		list=List.delete(list,nil)
		ifnil(list)
	else
		list
	end
	
end

#将数字拆开
def split(num,list) when num == 0 do
	Enum.reverse(list)
end

def split(num,list) do
	list = list ++ [rem(num,10)]
	split(div(num,10),list)
end

#将数字连接起来
def connect(list,_n,num) when list==[]do
	num
end

def connect(list,n,num) do
	len=length(list)
	n=n*(:math.pow(10,len-1) |> round)
	num=hd(list)*n+num
	n=1
	list=list--[hd(list)]
	connect(list,n,num)
end

#find all permutations  
def of([]) do
    [[]]
end

def of(list) do
    for h <- list, t <- of(list -- [h]), do: [h | t]
end
end

defmodule Boss do
	use GenServer

	def start_link(count,pid,n1,n2) do
		GenServer.start_link(__MODULE__,[count,pid,n1,n2])
	end

	def init(list) do
		range = tl(tl(list))
		n1 = hd(range)
		n2 = List.last(range)
		mGet(n1,n2)
		{:ok,list}
	end

	def mGet(n1,n2) when n1+99999>=n2 do
		bid = self()
		{:ok,pid}=Worker.start_link(bid,n1,n2)
		Worker.caculate(pid)
    end

	def mGet(n1,n2) do
		n3 = n1 + 99999
		bid = self()
		{:ok,pid}=Worker.start_link(bid,n1,n3)
		Worker.caculate(pid)
		n1 = n3 + 1
		mGet(n1,n2)
	end

	def print(pid, res) do
		GenServer.cast(pid, {:return, res})
	end

	def handle_cast({:return, res}, list) do
		count = hd(list)
		if res != [] , do: Enum.map(res,fn(x)->IO.puts(Enum.join(x," ")) end)
		tail = tl(list)
		if count-1 == 0 do
			send hd(tl(list)),{:finish}
		end
		{:noreply,[count-1] ++ tail}
	end
end

#defmodule Main do
#	def start(n1,n2) do
#		mid = self()
#		boss = spawn(Boss, :mGet, [n1,n2,mid])
#		n = div(n2,100000000)-div(n1,1000000)+1
#		waitSignal(n)
#	end
#
#	def waitSignal(n) when n == 0 do
#		IO.puts("finish000")
#	end
#	def waitSignal(n) do
#		IO.puts(n)
#		receive do
#			{:finish} -> waitSignal(n-1)
#		end
#	end
#end

defmodule Stack do
	use GenServer
  
	# Client
  
	def start_link(default) do
	  GenServer.start_link(__MODULE__, default)
	end

	# Server (callbacks)
  
	@impl true
	def init(counter) do
		IO.puts("im initialized by ")
		IO.inspect(counter)
		{:ok, counter}
	end
  

	def test(pid,exsID) do
		GenServer.cast(pid, {:test,exsID})
	end

	@impl true
	def handle_cast({:test,pid}, kk) do
		:timer.sleep(2000)
		send pid,{:finish}
		{:noreply, kk}
	  end
  end