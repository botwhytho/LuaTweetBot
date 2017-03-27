-- requires
require "os"
require "string-split"
local twitter = require "tweets"
local json = require "cjson"
local generateQuote = require "randomQuote"

-- ENV variables
local div = tonumber(os.getenv("div")) -- Threshold of short quotes vs long quotes (as percent of max length of tweet)
local topics = os.getenv("topics"):split("|") -- topics variable in .env file, separate with "|"
local numberOfTweets = tonumber(os.getenv("numberOfTweets")) -- Number of tweets before ending
local tweetSleep = tonumber(os.getenv("tweetSleep")) -- Number of seconds between tweets
local isDryRun = os.getenv("isDryRun") == "true" and true or false -- Is this a dry run? nothing will be tweeeted if so

math.randomseed(os.time())

local ffi = require "ffi"
ffi.cdef "unsigned int sleep(unsigned int seconds);" -- Using ffi to use the C sleep function

local sleep = function(n)  -- n = seconds
  ffi.C.sleep(n)
end

local respond = function(topic,bol) -- Searches twitter for a certain topic and tweets a random quote as a response to the latest tweet of the account with the greatest followers.
  local res = twitter.get("https://api.twitter.com/1.1/search/tweets.json",{{p="q",v=topic},{p="lang",v="en"}})
  local tweets = json.decode(res)
  if tweets.statuses ~= nil then
    table.sort(tweets.statuses, function(a,b) return a.user.followers_count > b.user.followers_count end)
    if not bol then
      local quote = generateQuote(div,tweets.statuses[1].user.screen_name)
      local res = twitter.get("https://api.twitter.com/1.1/statuses/user_timeline.json",{{p="user_id",v=tweets.statuses[1].user.id_str},{p="screen_name",v=tweets.statuses[1].user.screen_name}})
      local status = json.decode(res)
      local post = twitter.post("https://api.twitter.com/1.1/statuses/update.json",{{p="status",v=quote},{p="trim_user",v=1},{p="in_reply_to_status_id",v=status[1].id_str}})
      print(quote)
    else
      print(topic .. " | " .. generateQuote(div,json.statuses[1].user.screen_name) .. " - This is a dry run, nothing was tweeted.")
    end
  else
    print("No tweets found with that keyword. Nothing has been tweeted.")
  end
end

------------
--Test Code
------------

for i= 1,numberOfTweets do
	sleep(tweetSleep)
	respond(topics[math.random(1,#topics)],isDryRun)
end
