-- This example uses xmlua (high level lua bindings to libxml2 using luajit
-- FFI) to parse streaming xml. It uses libxml2 push/sax parser, so it has low
-- memory usage due to only a single top-level element being stored in memory
-- (in the example, we use <Event> tags as the top-level)
--
-- The resulting top-level element is returned as a single structured record for
-- processing in other layers.
local xmlua = require("xmlua")

local function create_parser(top_level_element)
  local result = nil
  local listener = {}
  local stack = {}
  -- local errors = {}
  function listener:start_element(local_name, _, _, _, attributes)
    if #stack == 0 and local_name:lower() ~= top_level_element then
      -- ignore
      return
    end
    local element = { tag = local_name }
    -- add attributes if the element has any
    if #attributes > 0 then
      element.attributes = {}
      for _, attr in ipairs(attributes) do
        element.attributes[attr.local_name] = attr.value
      end
    end
    -- add to the parent's children
    table.insert(stack, element)
  end
  function listener:text(text)
    text = text:gsub("^%s*(.-)%s*$", "%1") -- strip leading/trailing whitespace
    if text:len() == 0 then
      return
    end
    local parent = stack[#stack]
    if parent.text then
      -- concatenate with existing text
      parent.text = parent.text..text
    else
      parent.text = text
    end
  end
  function listener:end_element(local_name, ...)
    local element = stack[#stack]
    stack[#stack] = nil
    local parent = stack[#stack]
    if parent then
      if not parent.children then
        parent.children = {}
      end
      table.insert(parent.children, element)
    else
      result = element
    end
  end
  function listener:error(error)
    print('error', error)
  end
  local parser = xmlua.XMLStreamSAXParser.new(listener)
  local rv = {}
  function rv:parse(chunk)
    local rv = nil
    parser:parse(chunk)
    if result then
      rv = result
      result = nil
    end
    return rv
  end
  return rv
end

local parser = create_parser('event')

function process_record(tag, timestamp, record)
  local result = parser:parse(record.log)
  if result then
    -- fully parsed record
    return 2, timestamp, result
  else
    -- drop since the <Event> element is not complete yet
    return -1, timestamp, record
  end
end
