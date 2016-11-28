
local ffi = require "ffi"
local curl = require "lcurl"
local b64 = require "basexx"

local nonce = function(len)
  math.randomseed(os.time())
  local possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  local str = ""
  for k=1,len do
    n=math.random(1,#possible)
    str= str .. possible:sub(n,n)
  end
  return str
end

ffi.cdef[[
typedef struct evp_md_st EVP_MD;

const EVP_MD *EVP_sha1(void);

unsigned char *HMAC(const EVP_MD *evp_md, const void *key,
int key_len, const unsigned char *d, int n,
unsigned char *md, unsigned int *md_len);
]]

local ssl = ffi.load("/usr/lib/libssl.so")

twitter = {} -- Not local while testing through Lua REPL
twitter.params = {
  {p="oauth_consumer_key",v=consumerKey},
  {p="oauth_token",v=token},
  {p="oauth_signature_method",v="HMAC-SHA1"},
  {p="oauth_version",v="1.0"}
}

twitter.rest = function(op,url,query)
    local tmp = io.open("/dev/shm/tmp.txt","w+")
    oauth = {unpack(twitter.params)}
    table.insert(oauth, {p="oauth_timestamp",v=os.time()})
    table.insert(oauth,{p="oauth_nonce",v=nonce(6)})


    allParams = {unpack(oauth)}
    for k,v in ipairs(query) do
      table.insert(allParams,v)
    end

    table.sort(allParams,function(a,b) return a.p < b.p end)

    local req = curl.easy()

     baseString=""
     bs=""

    for _,v in ipairs(allParams) do
      baseString = baseString .. req:escape(v.p) .. "=" .. req:escape(v.v) .. "&"
    end

    baseString=baseString:sub(1,#baseString-1)
    bs= op .. "&" .. req:escape(url) .. "&" .. req:escape(baseString)

    local signature = ssl.HMAC(ssl.EVP_sha1(),
    req:escape(consumerSecret) .. "&" .. req:escape(tokenSecret),
    #(req:escape(consumerSecret) .. "&" .. req:escape(tokenSecret)),
    bs,
    #bs,
    nil,
    nil)

    local sig = b64.to_base64(ffi.string(signature))
    table.insert(allParams,{p="oauth_signature",v=sig})

    p="" --Local later

    for _,v in ipairs(allParams) do
      if not string.match(v.p,"oauth") then
        p = p .. req:escape(v.p) .. "=" .. req:escape(v.v)  .. "&"
      end
    end

    for _,v in ipairs(allParams) do
      if string.match(v.p,"oauth") then
        p = p .. v.p .. "=" .. req:escape(v.v)  .. "&"
      end
    end

    p = p:sub(1,#p-1)

    if op == "GET" then
      req:setopt_url(url .. "?" .. p)
    elseif op == "POST" then
      req:setopt_postfields(p)
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
