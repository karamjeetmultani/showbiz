-module(home_page_handler).
-author("sushmap@ybrantinc.com").

-export([init/3]).

-export([content_types_provided/2]).
-export([welcome/2]).
-export([terminate/3]).

%% Init
init(_Transport, _Req, []) ->
	{upgrade, protocol, cowboy_rest}.

%% Callbacks
content_types_provided(Req, State) ->
	{[		
		{<<"text/html">>, welcome}	
	], Req, State}.

terminate(_Reason, _Req, _State) ->
	ok.

%% API
welcome(Req, State) ->
	Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=2&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[Params] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	Latest_Gossips_Url = "http://api.contentapi.ws/videos?channel=world_news&skip=0&format=short&limit=3",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_Latest_Gossips} = ibrowse:send_req(Latest_Gossips_Url,[],get,[],[]),
	ResponseParams_Latest_Gossips = jsx:decode(list_to_binary(Response_Latest_Gossips)),	
	LatestGossipsParams = proplists:get_value(<<"articles">>, ResponseParams_Latest_Gossips),

	% Latest_News_Url = "http://api.contentapi.ws/news?channel=entertainment_film&skip=0&format=short&limit=4",
	Latest_News_Url = "http://contentapi.ws:5984/contentapi_text_maxcdn/_design/yb_entertainment_film/_view/full_composite_article?descending=true&limit=4",
	{ok, "200", _, Response_Latest_News} = ibrowse:send_req(Latest_News_Url,[],get,[],[]),
	ResponseParams_Latest_News = jsx:decode(list_to_binary(Response_Latest_News)),	
	LatestNewsParams = proplists:get_value(<<"rows">>, ResponseParams_Latest_News),
	% io:format("latestnews params url: ~p~n",[LatestNewsParams]),
	
	% Gallery_Url = "http://api.contentapi.ws/news?channel=entertainment_music&limit=4&skip=0&format=short",
	% % io:format("gallery url: ~p~n",[Gallery_Url]),
	% {ok, "200", _, Response_Gallery} = ibrowse:send_req(Gallery_Url,[],get,[],[]),
	% ResponseParams_Gallery = jsx:decode(list_to_binary(Response_Gallery)),	
	% GalleryParams = proplists:get_value(<<"articles">>, ResponseParams_Gallery),

	% Music_Url = "http://api.contentapi.ws/news?channel=entertainment_music&limit=4&skip=0&format=short",
	Music_Url = "http://contentapi.ws:5984/contentapi_text_maxcdn/_design/yb_entertainment_music/_view/long?descending=true&limit=4&skip=0",
	% io:format("gallery url: ~p~n",[Gallery_Url]),
	{ok, "200", _, Response_Music} = ibrowse:send_req(Music_Url,[],get,[],[]),
	ResponseParams_Music = jsx:decode(list_to_binary(Response_Music)),	
	MusicParams = proplists:get_value(<<"rows">>, ResponseParams_Music),

	Popular_Videos_Url = "http://api.contentapi.ws/videos?channel=world_news&skip=3&format=short&limit=8",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_Popular_Videos} = ibrowse:send_req(Popular_Videos_Url,[],get,[],[]),
	ResponseParams_Popular_Videos = jsx:decode(list_to_binary(Response_Popular_Videos)),	
	PopularVideosParams = proplists:get_value(<<"articles">>, ResponseParams_Popular_Videos),

	{ok, Body} = index_dtl:render([{<<"videoParam">>,Params},{<<"latestvideos">>,LatestGossipsParams},{<<"latestnews">>,LatestNewsParams},{<<"music">>,MusicParams},{<<"popularvideos">>,PopularVideosParams}]),
    {Body, Req, State}.
