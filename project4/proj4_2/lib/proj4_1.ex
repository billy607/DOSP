defmodule Proj41 do
	def main(num_user,num_msg) do
		{:ok,pidE} = Engine.start_link()
{:ok,pidC0} = Client.start_link(pidE)
{:ok,pidC1} = Client.start_link(pidE)
{:ok,pidC2} = Client.start_link(pidE)
{:ok,pidC3} = Client.start_link(pidE)
{:ok,pidC4} = Client.start_link(pidE)

Client.register(pidC0,"A","a")
Client.register(pidC1,"B","a")
Client.register(pidC2,"C","a")
Client.register(pidC3,"D","a")
Client.register(pidC4,"E","a")
:timer.sleep(50)

Client.login(pidC0,"A","a")
Client.login(pidC1,"B","a")
Client.login(pidC2,"C","a")
Client.login(pidC3,"D","a")
Client.login(pidC4,"E","a")
:timer.sleep(50)

Client.subscribe(pidC1,"A")
Client.subscribe(pidC2,"A")
:timer.sleep(50)

Client.send_tweet(pidC0,"im happy today #everyday @D ")
:timer.sleep(50)
Client.re_tweet(pidC1,"me too #everyday @C ",0)
:timer.sleep(20)

Client.query(pidC4,1,"everyday")
:timer.sleep(20)

IO.inspect(:ets.tab2list(:tweet),label: "tweet table")
IO.inspect(:sys.get_state(pidC1),label: "user B")
IO.inspect(:sys.get_state(pidC2),label: "user C")
IO.inspect(:sys.get_state(pidC3),label: "user D")
IO.inspect(:sys.get_state(pidC4),label: "user E")
:timer.sleep(50)

Client.logout(pidC0)
Client.logout(pidC1)
Client.logout(pidC2)
Client.logout(pidC3)
Client.logout(pidC4)

	end
end