Searches twitter for a certain topic and tweets a random quote as a response to the latest tweet of the account with the greatest number of followers.

Dependencies list and resource usage kept at a low level:
- cURL dev package on your machine
- LuaJIT ffi library (used to bind directly to libcrypto's HMAC function)
- lcurl cURL bindings
- cJSON Lua JSON parser bindings
- basexx Lua library (used for base64 conversions)
