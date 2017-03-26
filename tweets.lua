local curl = require "lcurl"
local HMAC = require "HMAC"

local twitter = {} -- Not local while testing through Lua REPL
twitter.params = {
  {p="oauth_consumer_key",v=os.getenv("consumerKey")},
  {p="oauth_token",v=os.getenv("token")},
  {p="oauth_signature_method",v="HMAC-SHA1"},
  {p="oauth_version",v="1.0"}
}

twitter.rest = function(op,url,query)
    local tmp = io.open("/dev/shm/tmp.txt","w+")

    local params = {unpack(twitter.params)}
    for k,v in ipairs(query) do
      table.insert(params,v)
    end

    local req = curl.easy()

    local paramString = HMAC.sign(req,op,url,params)

    if op == "GET" then
      req:setopt_url(url .. "?" .. paramString)
    elseif op == "POST" then
      req:setopt_postfields(paramString)
      req:setopt_url(url)
      req:setopt_httpheader{"content-type: application/x-www-form-urlencoded"}
    else
      --need to define other things to do if other http verbs are allowed
      req:setopt_url(url)
    end
    req:setopt_writefunction(tmp)
    req:perform()
    req:close()
    tmp:seek("set")
    local res = tmp:read("*all")
    tmp:close()
    return res

end

twitter.get = function(url,query)
    return twitter.rest("GET",url,query)
end

twitter.post = function(url,query)
    return twitter.rest("POST",url,query)
end

return twitter
