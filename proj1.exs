defmodule Vamp do 
	use GenServer
	def main do
		find(200,300,500,650)
		#{:ok,pid} = Vamp.start_link(:test)
		#Vamp.find(:test, [10,20,10,99])
	end

	def find(a,b,c,d) do
		numbers = a..b
		range = c..d
		combinations = Enum.flat_map(numbers, fn letter -> Enum.map(range, fn number -> [letter, number] end) end)
		results = Enum.map(combinations, fn x -> check_vamp(x) end)
		review_results(results)
	end

	def check_vamp(x) do
		a = Enum.min(x)
		b = Enum.max(x)
		product = a * b 
		if Integer.mod(a,10) == 0 and Integer.mod(b,10) == 0 do
			"false"
		else
			if String.length(to_string(a))*2 == String.length(to_string(product)) do 
				digits = Integer.digits(a) ++ Integer.digits(b)
				digits = Enum.sort(digits)

				prod = Integer.digits(product)
				prod = Enum.sort(prod)

				if digits == prod do
					[a,b]
				else
					"false"
				end
			else
				"false"
			end
		end
	end

	def review_results(results) do
		_res = List.flatten(Enum.uniq((Enum.filter(results, fn x -> x != "false" end))))
	end

	def start_link(numbers) do 
		GenServer.start_link(__MODULE__, numbers)
	end 

	def init(numbers) do 
		{:ok, numbers}
	end

	def state pid do 
		GenServer.call(pid, :state)
	end

	def handle_call(:state, _, state) do 
		{:reply, find(Enum.at(state,0), Enum.at(state,1), Enum.at(state,2), Enum.at(state,3)), state}
	end
end


defmodule Parent do
	use Supervisor

	def find_nums(a,_b,actors) do 
		digits = Kernel.trunc(String.length(to_string(a))/2) 
		nums = Enum.map(1..digits, fn _x -> 9 end) 
		vals = String.to_integer(Enum.join(nums)) 
		bot = Integer.floor_div(a,vals)  
		split_range(bot,vals,vals,actors)	
	end

	def split_range(a,b,c,actors) do
		elem = (b-a)/actors
		ranges = Enum.chunk_every(a..b,Kernel.trunc(elem)+1)
		_act_range = Enum.map(ranges, fn x -> [Enum.min(x)-1, Enum.max(x), a, c] end)
	end	

	def checkInput(input) do 
		if Integer.mod(String.length(to_string(input)),2) == 1 do
			IO.puts "Invalid Number"
		end
	end

##Supervisor stuff 
	def start_link(range) do 
		Supervisor.start_link(__MODULE__ ,range)
	end

	def init(range) do 
		actors = 100
		vals = find_nums(Enum.at(range,0), Enum.at(range,1),actors)
		children = Enum.map(vals, fn(x) -> worker(Vamp,[x], [id: x, restart: :permanent]) end)

		supervise(children, strategy: :one_for_one)
	end
end


a = String.to_integer(Enum.at(System.argv,0))
b = String.to_integer(Enum.at(System.argv,1))
{:ok, pid} = Parent.start_link([a,b])
Supervisor.count_children(pid)
ans = List.flatten(Enum.uniq(Enum.map(Supervisor.which_children(pid), fn x -> Vamp.state(Enum.at(Tuple.to_list(x),1)) end)))

answers = Enum.chunk_every(ans, 2)

final = List.flatten(Enum.uniq(Enum.filter(answers, fn x -> (Enum.at(x,0) * Enum.at(x,1)) > a and (Enum.at(x,0) * Enum.at(x,1)) < b end)))

IO.puts [Enum.join(final, " ")]
