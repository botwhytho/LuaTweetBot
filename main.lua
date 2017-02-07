local twitter = require "tweets"
local json = require "cjson"
local generateQuote = require "randomQuote"
local div = 0.6 -- Threshold of short quotes vs long quotes (as percent of max length of tweet)

math.randomseed(os.time())

local ffi = require "ffi"
ffi.cdef "unsigned int sleep(unsigned int seconds);" -- Using ffi to use the C sleep function

local sleep = function(n)  -- n = seconds
  ffi.C.sleep(n)
end

local respond = function(topic,bol) -- Searches twitter for a certain topic and tweets a random quote as a response to the latest tweet of the account with the greatest followers.
  local res = twitter.get("https://api.twitter.com/1.1/search/tweets.json",{{p="q",v=topic},{p="lang",v="en"}})
  local json = json.decode(res)
  if json.statuses ~= nil then
    table.sort(json.statuses, function(a,b) return a.user.followers_count > b.user.followers_count end)
    if bol then
      local post = twitter.post("https://api.twitter.com/1.1/statuses/update.json",{{p="status",v=generateQuote(div,json.statuses[1].user.screen_name)},{p="trim_user",v=1},{p="in_reply_to_status_id",v=json.statuses[1].id_str}})
    else
      print(generateQuote(div,json.statuses[1].user.screen_name) .. " - This is a dry run, nothing was tweeted.")
    end
  else
    print("No tweets found with that keyword. Nothing has been tweeted.")
  end
end

------------
--Test Code
------------

local topics = {"puppies","cats","fluffy clouds","LuaJIT"}

for i= 1,13 do
	sleep(2)
	respond(topics[math.random(1,#topics)],false)
end
