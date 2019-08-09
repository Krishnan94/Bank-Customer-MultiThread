-module(bank).
-compile(export_all).

startbankthread(BankName,Value) ->
	receive
		{Id} ->				
  				timer:sleep(100),
%%  				io:format("Calling ~w ~w ~w ~w ~n", [Id,self(),BankName,Value]),
				startbankthread(BankName,Value);
		{CustomerPid, CustomerName} ->
%% 			CustomerPid ! {CustomerPid,CustomerName},
			CustomerPid ! {CustomerPid},
			startbankthread(BankName,Value);
		{CustomerPid, AmountRequested,CustomerName} ->
%% 			io:fwrite("Request Recivied"),
%% 			io:fwrite("~w Request ~w dollars to ~w ~n",[CustomerName,AmountRequested,BankName]),
  			whereis(master) ! {1,CustomerName,BankName,AmountRequested},
%% 			io:fwrite("rbc approved the amount ~w",[Value]),
			
			if
				AmountRequested =< Value ->					
					Test=1,					
					CustomerPid ! {Test,AmountRequested,BankName},
					startbankthread(BankName,Value - AmountRequested);
				true ->						
					CustomerPid ! {0,AmountRequested,BankName},			
					startbankthread(BankName,Value)
			end
		after 2500 ->
 			whereis(master) ! {0,BankName,Value,1,Value}
				
	end.
	