local function dump(o, lvl)
  if lvl == nil then
    lvl = 0
  elseif lvl == 4 then
    return "..."
  end

  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
       if type(k) ~= 'number' then k = '"'..k..'"' end
       s = s .. '['..k..'] = ' .. dump(v, lvl+1) .. ','
       if lvl < 2 then s = s .. '\n' end
     end
     return s .. '} '
  else
    return tostring(o)
  end
end


local function printTable(t, hierarchyLevel)
	print(dump(t, hierarchyLevel))
end

rawset(_G, "printTable", printTable)

local function list_keys(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'],'
      end
      return s .. '} '
   end
end

local function getAllData(t, prevData)
  -- if prevData == nil, start empty, otherwise start with prevData
  local data = prevData or {}

  -- copy all the attributes from t
  for k,v in pairs(t) do
    data[k] = data[k] or v
  end

  -- get t's metatable, or exit if not existing
  local mt = getmetatable(t)
  if type(mt)~='table' then return data end

  -- get the __index from mt, or exit if not table
  local index = mt.__index
  if type(index)~='table' then return data end

  -- include the data from index into data, recursively, and return
  return getAllData(index, data)
end

local function printObj(obj, hierarchyLevel)
  if (hierarchyLevel == nil) then
    hierarchyLevel = 0
  elseif (hierarchyLevel == 4) then
    return 0
  end

  local whitespace = ""
  for i=0,hierarchyLevel,1 do
    whitespace = whitespace .. "-"
  end
  io.write(whitespace)

  print(obj)
  if (type(obj) == "table") then
    for _,v in pairs(obj) do
      io.write(whitespace .. "-")
      if (type(v) == "table") then
        printObj(v, hierarchyLevel+1)
      else
        print(v)
      end
    end
  else
    print(obj)
  end
end

local M = {
	dump = dump,
	list_keys = list_keys,
	getAllData = getAllData,
	printObj = printObj,
}

return M

