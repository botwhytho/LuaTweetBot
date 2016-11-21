
ffi = require "ffi"
curl = require "lcurl"
b64 = require "basexx"

nonce = function(len) 
  math.randomseed(os.time())
  possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
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

ssl = ffi.load("/usr/lib/libssl.so")

twitter = {}
twitter.params = {
  ["oauth_consumer_key"]=consumerKey,
  ["oauth_token"]=token,
  ["oauth_signature_method"]="HMAC-SHA1",
  ["oauth_version"]="1.0"
}

twitter.get = function(url,query)
    local rawdata = io.open("/dev/shm/rawdata.txt","w+")
    local oauth = {}
    oauth.oauth_timestamp = os.time()
    oauth.oauth_nonce = nonce(6)

    for k,v in pairs(twitter.params) do
      oauth[k] = v
    end

    local allParams = {}
    for k,v in ipairs(query) do
      table.insert(allParams,v)
    end

    for k,v in pairs(oauth) do
      table.insert(allParams,{p=k,v=v})
    end

    table.sort(allParams,function(a,b) return a.p < b.p end)

    local req = curl.easy()

    local baseString= "GET&" .. req:escape(url) .. "&"
    local bs=""

    for _,v in ipairs(allParams) do
      bs = bs .. req:escape(v.p) .. "=" .. req:escape(v.v) .. "&"
    end

    baseString=baseString .. req:escape(bs:sub(1,#bs-1))

    local signature = ssl.HMAC(ssl.EVP_sha1(),
    req:escape(consumerSecret) .. "&" .. req:escape(tokenSecret),
    #(req:escape(consumerSecret) .. "&" .. req:escape(tokenSecret)),
    baseString,
    #baseString,
    nil,
    nil)

    local sig = b64.to_base64(ffi.string(signature))
    table.insert(allParams,{p="oauth_signature",v=sig})

    local p=""

    for _,v in ipairs(query) do
      p = p .. req:escape(v.p) .. "=" .. req:escape(v.v) .. "&"
    end

    --p = p:sub(1,#p-1)


    local header = ""

    for _,v in ipairs(allParams) do
      if string.match(v.p,"oauth") then
        header = header .. v.p .. "=" .. req:escape(v.v)  .. "&"
      end
    end

    header = header:sub(1,#header-1)

    req:setopt_url(url .. "?" .. p .. header)
    req:setopt_writefunction(rawdata)
    req:perform()
    req:close()
    rawdata:close()

end

twitter.post = function(url,query)
    local rawdata = io.open("/dev/shm/rawdata.txt","w+")
    local oauth = {}
    oauth.oauth_timestamp = os.time()
    oauth.oauth_nonce = nonce(6)

    for k,v in pairs(twitter.params) do
      oauth[k] = v
    end

    local allParams = {}
    for _,v in ipairs(query) do
      table.insert(allParams,v)
    end

    for k,v in pairs(oauth) do
      table.insert(allParams,{p=k,v=v})
    end

    table.sort(allParams,function(a,b) return a.p < b.p end)

    local req = curl.easy()

    local baseString= "POST&" .. req:escape(url) .. "&"
    local bs=""

    for _,v in ipairs(allParams) do
      bs = bs .. req:escape(v.p) .. "=" .. req:escape(v.v) .. "&"
    end

    baseString=baseString .. req:escape(bs:sub(1,#bs-1))

    local signature = ssl.HMAC(ssl.EVP_sha1(),
    req:escape(consumerSecret) .. "&" .. req:escape(tokenSecret),
    #(req:escape(consumerSecret) .. "&" .. req:escape(tokenSecret)),
    baseString,
    #baseString,
    nil,
    nil)

    local sig = b64.to_base64(ffi.string(signature))
    table.insert(allParams,{p="oauth_signature",v=sig})

    local p=""

    for _,v in ipairs(query) do
      p = p .. req:escape(v.p) .. "=" .. req:escape(v.v) .. "&"
    end


    local header = ""

    for _,v in ipairs(allParams) do
      if string.match(v.p,"oauth") then
        header = header .. v.p .. "=" .. req:escape(v.v)  .. "&"
      end
    end

    header = header:sub(1,#header-1)

    req:setopt_postfields(p .. header)
    req:setopt_url(url)
    req:setopt_httpheader{"content-type: application/x-www-form-urlencoded"}
    req:setopt_writefunction(rawdata)
    req:perform()
    req:close()
    rawdata:close()

end
