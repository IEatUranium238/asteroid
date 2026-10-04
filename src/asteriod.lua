local m = {}

local default_params = {
  allow_undefined = false,
  default = nil,
  escaper = nil
}

--- @class Template
local template = {}

--- Make a new template object
--- @param in_data table parsed template data
--- @param in_params? table default parameters for generators
--- @return Template template template object
function template:new(in_data, in_params)
  local obj = {
    data = in_data,
    params = in_params
  }

  setmetatable(obj, self)
  self.__index = self

  return obj
end

-- TODO: add logic
function template:generate()
  return "hi"
end

--- Make a new Asteroid template
--- @param in_string string string to template
--- @param in_params? table default parameters for generators
--- @return Template template Asteroid template object
function m.make_template(in_string, in_params)
  in_string = in_string:gsub("^%s*(.-)%s*$", "%1")

  if (in_string == "") then
    error("Can't use empty data input to template", 2)
  end

  local data = {}
  local buffer = ""
  local escape_mode = false
  local value_mode = false

  -- Scan and populate data
  for i = 1, #in_string do
    local c = in_string:sub(i, i)

    if (escape_mode) then
      buffer = buffer .. c
      escape_mode = false
    elseif (c == "\\" and not value_mode) then -- Escaping
      escape_mode = true
    elseif (c == "@" and not value_mode) then  -- Value start
      if (buffer ~= "") then
        table.insert(data, { type = "text", data = buffer })
      end

      value_mode = true
      buffer = ""
    elseif (value_mode and (c == " " or c == "!")) then -- Value end
      if (buffer ~= "") then
        table.insert(data, { type = "value", data = buffer })
      end

      value_mode = false
      buffer = ""
    else
      buffer = buffer .. c
    end
  end

  -- Insert any leftovers in the buffer
  if (buffer ~= "") then
    table.insert(data, {
      type = value_mode and "value" or "text",
      data = buffer
    })
  end

  local generatedObj = template:new(data, in_params)

  return generatedObj
end

return m
