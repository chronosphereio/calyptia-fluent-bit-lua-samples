-- import the "digest" openssl submodule, which contains implementations of
-- multiple cryptographic hash algorithms
local digest = require 'openssl.digest'

local function tohex(bytes)
  local x = {}
  for i=1, #bytes do
    table.insert(x, string.format("%.2x", string.byte(bytes, i)))
  end
  return table.concat(x, "")
end

local function digest_factory(algorithm)
  return function(str)
    local digest = digest.new(algorithm)
    return tohex(digest:final(str))
  end
end

local md5 = digest_factory('md5')
local sha1 = digest_factory('sha1')
local sha256 = digest_factory('sha256')

function process_record(tag, timestamp, record)
  record.md5 = md5(record.log)
  record.sha1 = sha1(record.log)
  record.sha256 = sha256(record.log)
  return 1, timestamp, record
end
