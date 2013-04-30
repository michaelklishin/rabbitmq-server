%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is VMware, Inc.
%% Copyright (c) 2007-2013 VMware, Inc.  All rights reserved.
%%

-module(rabbit_paths).
-include("rabbit.hrl").


-export([vhosts_dir/0, vhost_dir/1, queue_dir/1,
        queue_name_to_dir_name/1, vhost_name_to_dir_name/1,
        all_queue_directory_names/1,
        legacy_queues_dir/0, legacy_queue_dirs/0, legacy_queue_dir/1,
        legacy_all_queue_directory_names/1]).


vhosts_dir() ->
    %% adding  here makes it easier to tell queue directories that belong to the old layout
    %% from vhost directories. MK.
    filename:join(rabbit_mnesia:dir(), "vhosts").

vhost_dir(VHost) ->
    filename:join(vhosts_dir(), vhost_name_to_dir_name(VHost)).

queue_dir(QueueName = #resource{virtual_host = VHost, kind = queue}) ->
    filename:join([vhost_dir(VHost), "queues", queue_name_to_dir_name(QueueName)]).

queue_name_to_dir_name(Name = #resource { kind = queue }) ->
    rabbit_misc:md5binary(Name).

vhost_name_to_dir_name(VHost) ->
    rabbit_misc:md5binary(VHost).

all_queue_directory_names(VhostsDir) ->
    case rabbit_file:list_dir(VhostsDir) of
        {ok, _Entries}   ->
            Pattern = filename:join([VhostsDir, "*", "*"]),
            lists:filter(fun rabbit_file:is_dir/1, filelib:wildcard(Pattern));
        {error, enoent} -> []
    end.


%% pre per-vhost separation
legacy_queues_dir() ->
    filename:join(rabbit_mnesia:dir(), "queues").

legacy_queue_dirs() ->
    Pattern = filename:join([rabbit_mnesia:dir(), "queues", "*"]),
    lists:filter(fun rabbit_file:is_dir/1, filelib:wildcard(Pattern)).

legacy_queue_dir(Name = #resource{kind = queue}) ->
    filename:join(legacy_queues_dir(), queue_name_to_dir_name(Name)).

legacy_all_queue_directory_names(Dir) ->
    case rabbit_file:list_dir(Dir) of
        {ok, Entries}   -> [ Entry || Entry <- Entries,
                                      rabbit_file:is_dir(
                                        filename:join(Dir, Entry)) ];
        {error, enoent} -> []
    end.
