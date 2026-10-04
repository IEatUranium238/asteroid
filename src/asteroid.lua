local m = {}

--- @class Template_Params
--- @field allow_undefined boolean | nil
--- @field allow_override boolean | nil
--- @field default any
--- @field default_values table | nil
--- @field escaper nil | function
local default_params = {
  allow_undefined = false,
  allow_override = false,
  default = "nil",
  default_values = {},
  escaper = nil,
}

--- @class Template
--- @field params table
--- @field data table
local template = {}

--- Make a new template object
--- @param in_data table parsed template data
--- @param in_params? Template_Params default parameters for generators
--- @return Template template template object
function template:new(in_data, in_params)
  local obj = {
    data = in_data,
    params = default_params
  }

  if (in_params ~= nil) then
    for k, v in pairs(in_params) do
      obj.params[k] = v
    end
  end

  setmetatable(obj, self)
  self.__index = self

  return obj
end

--- Generate templated result string of the template
--- @param values table values to template with
--- @param config? Template_Params parameters for this generator
--- @return string result result string
function template:generate(values, config)
  -- Configuration
  if (config ~= nil) then
    if (self.params.allow_override == false) then
      error("Can't override settings for this generator!\nUse allow_override on template creator to allow overriding", 2)
    end

    -- Merge generator's configuration
    local copy = self.params

    for k, v in pairs(config) do
      copy[k] = v
    end

    config = copy
  else
    config = self.params
  end

  local res = ""

  for _, item in pairs(self.data) do
    if (item.type == "text") then
      res = res .. item.data
    else
      local val_name = item.data
      local val_value = values[val_name]

      -- Check if undefined
      if (val_value == nil) then
        if (config.allow_undefined == false) then
          error(
            "Value '" ..
            val_name ..
            "' is undefined (nil)!\nSet allow_undefined to use default or specific default for this value from default_values.",
            2)
        end

        -- Search in specific values first
        if (config.default_values[val_name] ~= nil) then
          val_value = config.default_values[val_name]
        else
          val_value = config.default
        end
      end

      -- Use escaper if defined
      if (config.escaper ~= nil) then
        val_value = config.escaper(val_value)
      end

      res = res .. val_value
    end
  end

  return res
end

--- Make a new Asteroid template
--- @param in_string string string to template
--- @param in_params? Template_Params default parameters for generators
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

      if (c == " ") then
        buffer = " "
      else
        buffer = ""
      end
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
