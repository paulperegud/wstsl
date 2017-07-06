%%%-------------------------------------------------------------------
%% @doc wstls public API
%% @end
%%%-------------------------------------------------------------------

-module(wstls_app).
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_Type, _Args) ->
    D = [{'_', [
                {"/", cowboy_static, {priv_file, websocket, "index.html"}},
                {"/websocket", ws_handler, []},
                {"/static/[...]", cowboy_static, {priv_dir, websocket, "static"}}
               ]}],
    Dispatch = cowboy_router:compile(D),
    PrivDir = code:priv_dir(websocket),
    io:fwrite("~nPrivDir: ~p~n", [PrivDir]),
    {ok, _} = cowboy:start_tls(https,
                               [{cacertfile, PrivDir ++ "/ssl/cowboy-ca.crt"},
                                {certfile, PrivDir ++ "/ssl/server.crt"},
                                {keyfile, PrivDir ++ "/ssl/server.key"},
                                {port, 8443}],
                               #{ env => #{dispatch => Dispatch} }),
    wstls_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
