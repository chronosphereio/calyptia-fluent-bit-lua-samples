-- This file contains some examples of how to use third party lua libraries to
-- implement a fluent-bit lua filter.

-- The lua instance embedded into fluent-bit can load libraries in the standard
-- LUA_PATH, which is where luarocks (a popular lua package manager) installs
-- libraries by default. So a docker image can easily install luarocks packages
-- to extend fluent-bit lua filter capabilities. See Dockerfile in the same
-- directory for examples of how lua libraries can be installed.

-- "base64" is a simple lua library to handle base64 encoding
local base64 = require 'base64'
-- "rex_pcre2" is part of a package that exposes multiple of regular expression
-- engines to lua. Here we chose "PCRE2" as the variant, which is the version 2
-- of perl-compatible regular expressions.
local rex = require 'rex_pcre2'

local flags = rex.flags()
-- compile a regular expression pattern to extract certain keys from log
-- messages. Note that we pass CASELESS to ignore case when matching, and
-- EXTENDED to ignore whitespace in the pattern. EXTENDED allows us to create
-- more readable regular expression using a lua multiline string.
local pattern = rex.new([[
  (ssn|severity|ip\s+address)  # key
  \s*:\s*                      # k/v delimiter
  ([^,]+)                      # value
  ]], flags.CASELESS + flags.EXTENDED)

-- The filter is split into three functions, where each does a different kind of
-- processing to the log message

-- The first one simply encodes the whole contents of the log to base64 into a
-- new record field named "encoded"
local function base64_encode(tag, timestamp, record)
  record.encoded = base64.encode(record.log)
end

-- The second one uses the compiled regular expression to extract and parse
-- certain keys from the log message. The extracted keys/values are added to the
-- record as individual entries.
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

-- This is just an example of how one can create arrays in the record.
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

function cb_filter(tag, timestamp, record)
  base64_encode(tag, timestamp, record)
  parse_fields(tag, timestamp, record)
  add_calculated_fields(tag, timestamp, record)
  -- The return code 1 means both the record and the timestamp were modified. In
  -- this case, we could have returned 2, since we don't modify the timestamp.
  -- If 0 is returned, the record is not modified, even if we make changes to
  -- the "record" table. -1 is returned when we want to drop the record.
  return 1, timestamp, record
end
