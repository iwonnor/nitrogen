% Nitrogen Web Framework for Erlang
% Copyright (c) 2008-2009 Rusty Klophaus
% See MIT-LICENSE for licensing information.

-module (default_process_cabinet_handler).
-behaviour (process_cabinet_handler).
-include ("simplebridge.hrl").
-include ("wf.inc").
-export ([
	init/2, 
	finish/2,
	get_pid/3,
	get_pid/4
]).

-define (TABLE, process_cabinet).

init(Context, State) -> 
	% case lists:member(?TABLE, ets:all()) of
	% 	true -> ok;
	% 	false -> 
	% 		F = fun() -> ?TABLE = ets:new(process_cabinet, [set, public, named_table]), timer:sleep() end,
	% 		erlang:spawn(F)
	% end,
	{ok, Context, State}.

finish(Context, State) ->
	{ok, Context, State}.
	
get_pid(Key, Context, State) -> 
	Pid = case ets:lookup(?TABLE, Key) of
		[] -> undefined;
		[{Key, Value}] -> Value
	end,
	{ok, Pid, Context, State}.

get_pid(Key, Function, Context, State) ->
	{ok, Pid, Context1, State1} = get_pid(Key, Context, State),
	Pid1 = case Pid /= undefined andalso is_pid(Pid) andalso is_process_alive(Pid) of
		true  -> Pid;
		false -> 
			NewPid = erlang:spawn(Function),
			ets:insert(?TABLE, {Key, NewPid}),
			NewPid
	end,
	{ok, Pid1, Context1, State1}.