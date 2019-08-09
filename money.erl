-module(money).
-import(customer, [startthread/2]).
-import(bank, [startbankthread/2]).
-compile(export_all).

hello() ->
	Input = file:consult("banks.txt"),	
	ListInput=element(2,Input),
%% 	io:fwrite("** Calls to be made ** ~n" ),
%% 	io:fwrite("~n"),
	Bank=maps:from_list(ListInput),
	BankPid=maps:new(),	
	Inputcustomer = file:consult("customers.txt"),	
	ListInput1=element(2,Inputcustomer),
%% 	io:fwrite("** Calls to be made ** ~n" ),
%% 	io:fwrite("~n"),
	CustomerPid=maps:new(),	
	Customer=maps:from_list(ListInput1),
%% 	io:fwrite("list",[maps:to_list(Bank)]),
	BankList=maps:keys(Bank),	
	io:fwrite("** Customers and loan objectives ** ~n" ),
 	maps:fold(fun(CustomerName, Value, ok) -> io:format("~p: ~p~n", [CustomerName, Value]) end, ok, Customer),
	io:fwrite("** Banks and financial resources ** ~n" ),
	maps:fold(fun(BankName, Value, ok) -> io:format("~p: ~p~n", [BankName, Value]) end, ok, Bank),
		
	
Fun2=fun(Bankname,Value,Acc) ->
	%timer:sleep(round(timer:seconds(random:uniform()))),
	Pid = spawn(bank, startbankthread, [Bankname,Value]),
	Pid ! {self()},
	register(Bankname,Pid)
	end,
	maps:fold(Fun2,[],Bank),

Fun1=fun(CustomerName,Value,Acc) ->
	%timer:sleep(round(timer:seconds(random:uniform()))),
	Pid = spawn(customer, startthread, [CustomerName,Value,Value,BankList]),	
	Pid ! {self()},
	register(CustomerName,Pid)
	end,
	maps:fold(Fun1,[],Customer).	

intiate()->
receive
		{Id} ->
			hello(),
			intiate();
		{Test,CustomerName,BankName,AmountRequested} ->
			if
				Test==1 ->
					io:fwrite("~w Request ~w dollars to ~w ~n",[CustomerName,AmountRequested,BankName]),
					intiate();
				true ->
					if
						Test==0 ->
							io:fwrite("~w approves a loan of ~w dollars from ~w ~n",[BankName,AmountRequested,CustomerName]),
							intiate();
						true ->
							io:fwrite("~w rejects a loan of ~w dollars from ~w ~n",[BankName,AmountRequested,CustomerName]),
							intiate()
					end
			end;
		{Type,Name,Amount,Sucess,FinalAmount} ->
			if
				Type==1 ->
					if
						Sucess == 0 ->
							io:format("~w has reached the objective of whole ~w dollar(s). Woo Hoo!~n",[Name,Amount]),
							intiate();
						true ->
							io:format("~w was only able to borrow ~w dollar(s). Boo Hoo!~n",[Name,Amount]),
							intiate()
					end;
				true ->
					io:format("~w has ~w dollar(s) remaining.~n",[Name,Amount]),
					intiate()
			end
		after 3000 ->
			exit(self(), ok)
end.

start()->
	Pid = spawn(money, intiate, []),
	Pid ! {self()},
	register(master,Pid),
	timer:sleep(4000).