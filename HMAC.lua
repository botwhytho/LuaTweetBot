local ffi = require "ffi"
local b64 = require "basexx"

ffi.cdef[[
typedef struct evp_md_st EVP_MD;

const EVP_MD *EVP_sha1(void);

unsigned char *HMAC(const EVP_MD *evp_md, const void *key,
int key_len, const unsigned char *d, int n,
unsigned char *md, unsigned int *md_len);
]]

local ssl = ffi.load("/usr/lib/libssl.so")

local HMAC = {}

HMAC.nonce = function(len)
  math.randomseed(os.time())
  local possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  local str = ""
  for k=1,len do
    n=math.random(1,#possible)
    str= str .. possible:sub(n,n)
  end
  return str
end

HMAC.sign = function(req,op,url,params)

  table.insert(params, {p="oauth_timestamp",v=os.time()})
  table.insert(params,{p="oauth_nonce",v=HMAC.nonce(6)})
  table.sort(params,function(a,b) return a.p < b.p end)

  local baseString=""
  local bs=""

  for _,v in ipairs(params) do
   baseString = baseString .. req:escape(v.p) .. "=" .. req:escape(v.v) .. "&"
  end

  baseString=baseString:sub(1,#baseString-1)
  bs= op .. "&" .. req:escape(url) .. "&" .. req:escape(baseString)

  local signature = ssl.HMAC(ssl.EVP_sha1(),
  req:escape(os.getenv("consumerSecret")) .. "&" .. req:escape(os.getenv("tokenSecret")),
  #(req:escape(os.getenv("consumerSecret")) .. "&" .. req:escape(os.getenv("tokenSecret"))),
  bs,
  #bs,
  nil,
  nil)

  local sig = b64.to_base64(ffi.string(signature))
  table.insert(params,{p="oauth_signature",v=sig})

  local p = ""

  for _,v in ipairs(params) do
   if not string.match(v.p,"oauth") then
     p = p .. req:escape(v.p) .. "=" .. req:escape(v.v)  .. "&"
   end
  end

  for _,v in ipairs(params) do
   if string.match(v.p,"oauth") then
     p = p .. v.p .. "=" .. req:escape(v.v)  .. "&"
   end
  end

  p = p:sub(1,#p-1)
  return p

end

return HMAC
