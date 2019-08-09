-module(customer).
-compile(export_all).

startthread(CustomerName,Amount,FianalAmount,Bankdetails) ->
	receive
		{Id} ->					
%%   				io:format("Calling ~w ~w ~w ~w ~w ~n", [Id,self(),CustomerName,Amount,random:uniform(50)]),
%%  				io:format("Calling inside ~w ~n",[length(Bankdetails)]),
%% 				Bankdetails=randombankgenaration(),
  				timer:sleep(100),
%% 				self() ! {self(),CustomerName},
%% 				startthread(CustomerName,Amount,FianalAmount,Bankdetails);
%% 		{Id,CustomerName} ->			
				Index = length(Bankdetails),
%% 				AmountReq=rand:uniform(50),
%%  				io:format("~w requests a loan of ~w dollar(s) from ~w ~n",[CustomerName,AmountReq,(lists:nth(Index,Bankdetails))]),
				if
					Index==0 ->
%% 						io:fwrite("No more Banks to request"),
						startthread(CustomerName,Amount,FianalAmount,Bankdetails);
					true ->
						if
								Amount > 50 ->
 									timer:sleep(rand:uniform(100)),
									whereis((lists:nth(rand:uniform(length(Bankdetails)),Bankdetails))) ! {self(),rand:uniform(50),CustomerName},
									startthread(CustomerName,Amount,FianalAmount,Bankdetails);
								true ->
 									timer:sleep(100),
									whereis((lists:nth(rand:uniform(length(Bankdetails)),Bankdetails))) ! {self(),Amount,CustomerName},	
									startthread(CustomerName,Amount,FianalAmount,Bankdetails)
						end
				end;					
		{Test,AmountRequested,BankName} ->
			if
				Test==1 ->
 					whereis(master) ! {0,CustomerName,BankName,AmountRequested},
%% 					io:fwrite("~w approves a loan of ~w dollars from ~w ~n",[BankName,AmountRequested,CustomerName]),
					if
						Amount - AmountRequested >= 50 ->							 
%% 							io:format("Calling ~w~n",[(lists:nth(rand:uniform(length(Bankdetails)),Bankdetails))]),
							Index = rand:uniform(length(Bankdetails)),
 							timer:sleep(rand:uniform(100)),
							whereis((lists:nth(rand:uniform(length(Bankdetails)),Bankdetails))) ! {self(),rand:uniform(50),CustomerName},	
							startthread(CustomerName,Amount-AmountRequested,FianalAmount,Bankdetails);
						true ->
							if
								(Amount - AmountRequested) == 0 ->
%% 									io:fwrite("Amount Done ~w ~n",[CustomerName]),
									startthread(CustomerName,Amount-AmountRequested,FianalAmount,Bankdetails);
								true ->
									timer:sleep(rand:uniform(100)),
									whereis((lists:nth(rand:uniform(length(Bankdetails)),Bankdetails))) ! {self(),Amount-AmountRequested,CustomerName},	
									startthread(CustomerName,Amount-AmountRequested,FianalAmount,Bankdetails)
							end																
					end;					
				true ->
 					whereis(master)!{2,CustomerName,BankName,AmountRequested},
%% 					io:fwrite("~w rejects a loan of ~w dollars from ~w ~n",[BankName,AmountRequested,CustomerName]),
%% 					NewBankdetails=lists:delete(BankName, Bankdetails),					
%% 					io:format("~w requests a loan of ~w dollar(s) from ~w ~n",[CustomerName,AmountReq,(lists:nth(Index,Bankdetails))]),
					whereis(BankName) ! {self(),CustomerName},
					startthread(CustomerName,Amount,FianalAmount,lists:delete(BankName, Bankdetails))
			end
		after 2000 ->
			if
				Amount == 0 ->					
 					whereis(master) ! {1,CustomerName,FianalAmount-Amount,0,FianalAmount};
				true ->
					whereis(master) ! {1,CustomerName,FianalAmount-Amount,1,FianalAmount}
			end	
	end.

randombankgenaration() ->
	io:fwrite("Format~n").