defmodule Proj41Test do
  use ExUnit.Case

  test "register" do
	IO.puts("test register")
    {:ok,pidE} = Engine.start_link()
	IO.inspect(:ets.tab2list(:user),label: "user table(before register)")
	{:ok,pidC0} = Client.start_link(pidE)
	Client.register(pidC0,"A","a")
	:timer.sleep(50)
	IO.inspect(:ets.tab2list(:user),label: "user table(after register)")
	IO.puts("\n")
  end
  
  test "login0" do
	IO.puts("login test 0")
    {:ok,pidE} = Engine.start_link()
	{:ok,pidC0} = Client.start_link(pidE)
	Client.register(pidC0,"A","a")
	:timer.sleep(50)	
	IO.inspect(:ets.tab2list(:user),label: "user table(before login)")
	Client.login(pidC0,"A","a")
	:timer.sleep(50)
	IO.inspect(:ets.tab2list(:user),label: "login table(after login)")
	IO.puts("the last variable indicates states of login")
	IO.puts("\n")
  end
  
   test "login1" do
	IO.puts("login test 1")
    {:ok,pidE} = Engine.start_link()
	{:ok,pidC0} = Client.start_link(pidE)
	Engine.demo(pidE)
	Client.login(pidC0,"A","a")
	IO.inspect(Enum.at(:sys.get_state(pidC0),4),label: "user A sub_tweet")
	IO.inspect(Enum.at(:sys.get_state(pidC0),5),label: "user A men_tweet")
	IO.puts("\n")
  end
  
  test "subscribe" do
	IO.puts("subscribe test")
	{:ok,pidE} = Engine.start_link()
	{:ok,pidC0} = Client.start_link(pidE)
	{:ok,pidC1} = Client.start_link(pidE)
	Client.register(pidC0,"A","a")
	Client.register(pidC1,"B","a")
	:timer.sleep(50)
	Client.login(pidC0,"A","a")
	Client.login(pidC1,"B","a")
	:timer.sleep(50)
	IO.inspect(:ets.tab2list(:subscribe),label: "subscribe table(before subscribe)")
	Client.subscribe(pidC1,"A")
	:timer.sleep(50)
	IO.inspect(:ets.tab2list(:subscribe),label: "subscribe table(after subscribe)")
	IO.puts("\n")
  end
  
  test "send" do
	IO.puts("send test")
	{:ok,pidE} = Engine.start_link()
	{:ok,pidC0} = Client.start_link(pidE)
	{:ok,pidC1} = Client.start_link(pidE)
	{:ok,pidC2} = Client.start_link(pidE)
	{:ok,pidC3} = Client.start_link(pidE)

	Client.register(pidC0,"A","a")
	Client.register(pidC1,"B","a")
	Client.register(pidC2,"C","a")
	Client.register(pidC3,"D","a")
	:timer.sleep(50)

	Client.login(pidC0,"A","a")
	Client.login(pidC1,"B","a")
	Client.login(pidC2,"C","a")
	Client.login(pidC3,"D","a")
	:timer.sleep(50)

	Client.subscribe(pidC1,"A")
	Client.subscribe(pidC2,"A")
	:timer.sleep(50)

	Client.send_tweet(pidC0,"im happy today #everyday @D ")
	:timer.sleep(50)
	IO.inspect(:ets.tab2list(:tweet),label: "tweet table(after send)")
	IO.inspect(:ets.tab2list(:hashTags),label: "hashTags table")
	IO.inspect(:ets.tab2list(:mention),label: "mention table")
	IO.inspect(Enum.at(:sys.get_state(pidC1),4),label: "user B")
	IO.inspect(Enum.at(:sys.get_state(pidC2),4),label: "user C")
	IO.inspect(Enum.at(:sys.get_state(pidC3),5),label: "user D")
	IO.puts("\n")
  end
  
  test "logout" do
	IO.puts("logout test")
	{:ok,pidE} = Engine.start_link()
	{:ok,pidC0} = Client.start_link(pidE)
	Client.register(pidC0,"A","a")
	:timer.sleep(50)
	Client.login(pidC0,"A","a")
	:timer.sleep(50)
	IO.inspect(:ets.tab2list(:user),label: "user table(before logout)")
	Client.logout(pidC0)
	:timer.sleep(50)
	IO.inspect(:ets.tab2list(:user),label: "user table(after logout)")
	IO.puts("\n")
  end
  
  test "query" do
	IO.puts("query test")
	{:ok,pidE} = Engine.start_link()
	{:ok,pidC0} = Client.start_link(pidE)
	{:ok,pidC4} = Client.start_link(pidE)

	Client.register(pidC0,"A","a")
	Client.register(pidC4,"E","a")
	:timer.sleep(50)

	Client.login(pidC0,"A","a")
	Client.login(pidC4,"E","a")
	:timer.sleep(50)

	Client.send_tweet(pidC0,"im happy today #everyday  ")
	Client.send_tweet(pidC0,"im sad today #everyday ")
	Client.send_tweet(pidC0,"hello world @D ")
	:timer.sleep(50)
	Client.query(pidC4,0,"A")
	:timer.sleep(20)
	IO.inspect(Enum.at(:sys.get_state(pidC4),6),label: "query 'user A'")
	
	Client.query(pidC4,1,"everyday")
	:timer.sleep(20)
	IO.inspect(Enum.at(:sys.get_state(pidC4),6),label: "query '#everyday'")
	
	Client.query(pidC4,2,"D")
	:timer.sleep(20)
	IO.inspect(Enum.at(:sys.get_state(pidC4),6),label: "query '@D'")
	
	IO.puts("\n")
  end
  
  test "delete" do
	IO.puts("delete test")
	{:ok,pidE} = Engine.start_link()
	{:ok,pidC0} = Client.start_link(pidE)
	Client.register(pidC0,"A","a")
	:timer.sleep(50)
	Client.login(pidC0,"A","a")
	:timer.sleep(50)
	IO.inspect(:ets.tab2list(:user),label: "user table(before delete)")
	Client.delete(pidC0)
	:timer.sleep(50)
	IO.inspect(:ets.tab2list(:user),label: "user table(after delete)")
	IO.puts("\n")
  end
  
  test "retweet" do
	IO.puts("retweet test")
	{:ok,pidE} = Engine.start_link()
	{:ok,pidC0} = Client.start_link(pidE)
	{:ok,pidC1} = Client.start_link(pidE)
	Client.register(pidC0,"A","a")
	Client.register(pidC1,"B","a")
	:timer.sleep(10)
	Client.login(pidC0,"A","a")
	Client.login(pidC1,"B","a")
	:timer.sleep(10)
	Client.send_tweet(pidC0,"im happy today #everyday @D ")
	:timer.sleep(10)
	IO.inspect(:ets.tab2list(:tweet),label: "before retweet")
	Client.re_tweet(pidC1,"im happy too",0)
	:timer.sleep(10)
	IO.inspect(:ets.tab2list(:tweet),label: "after retweet")
	IO.puts("\n")
  end
end
