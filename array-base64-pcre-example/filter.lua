local base64 = require 'base64'
local rex = require 'rex_pcre2'

local flags = rex.flags()
local pattern = rex.new([[
  (ssn|severity|ip\s+address)  # key
  \s*:\s*                      # k/v delimiter
  ([^,]+)                      # value
  ]], flags.CASELESS + flags.EXTENDED)

local function base64_encode(tag, timestamp, record)
  record.encoded = base64.encode(record.log)
end

local function parse_fields(tag, timestamp, record)
  local log = record.log
  -- local key = nil
  for key, value in rex.gmatch(record.log, pattern) do
    key = key:lower()
    if key == 'severity' then
      value = tonumber(value)
    end
    record[key] = value
  end
  record.log = nil
end

local function add_calculated_fields(tag, timestamp, record)
  -- example of how to create an "array literal"
  record.tag3 = {
    { key1 = 'value1', key2 = 'value2'},
    { key1 = 'value3', key2 = 'value4'},
    { key1 = 'value5', key2 = 'value6'},
  }
  -- example of how to append items to an array
  table.insert(record.tag3, { key1 = 'value7', key2 = 'value8'})
  table.insert(record.tag3, { key1 = 'value9', key2 = 'value10'})
end

function process_record(tag, timestamp, record)
  base64_encode(tag, timestamp, record)
  parse_fields(tag, timestamp, record)
  add_calculated_fields(tag, timestamp, record)
  return 1, timestamp, record
end
