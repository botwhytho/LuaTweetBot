local quotes = require "quotes" --quotes is a lua file with a table that has the following format (example below) quotes with their pre-computed length in ascending order
													--local t = {{q="Be brave.", l=9}, {q="There it is.", l=12}, {q="There we go.", l=12}}
													--return t

math.randomseed(os.time())

local wisdom = function(div,handle) --Picking a random longer quote from the list.
	local high = #quotes
	local low = 1

	for k,v in ipairs(quotes) do --Determine lower bound for random set so that if only one quote, the quotes are long
		if v.l > (140-#handle)*div then
			low = k-1
			break
		end
	end

	for k,v in ipairs(quotes) do --Picking the max length depending on handle length
		if v.l > 140-#handle then
			high = k-1
			break
		end
	end

	return handle .. quotes[math.random(low,high)].q

end

local doubleTrouble = function(div,handle) --Picking two shorter quotes  and combining them together. Let the randomness begin.
	high = #quotes

	for k,v in ipairs(quotes) do --Pick max length to combine two short quotes
		if v.l > (140-#handle)*div then
			high = k-1
      break
		end
	end


	local n = math.random(1,high)
	double = quotes[n].q

	local n2 = math.random(1,high)
  high = n2

	while #handle + #double + #quotes[n2].q > 140 do
    high=high-1
		n2 = math.random(1,high)
	end

	return handle .. double .. " " .. quotes[n2].q

end


local generateQuote = function(div,handle) --Randomly choose between a longer quote or two shorter quotes combined
  tmp = math.random(1,2)

  if tmp == 1 then
    return wisdom(div,handle)
  else
    return doubleTrouble(div,handle)
  end
end

return generateQuote
