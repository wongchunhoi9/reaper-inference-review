-- Inference Review and Presentation dev bridge (temporary, for testing only).
-- Runs dev/cmd.lua whenever its first line (an id) changes; writes results to dev/out.txt.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
_G.IRP_DEV_DIR = dir                       -- .../dev/
_G.IRP_ROOT = dir:gsub("[/\\]dev[/\\]$", "/") -- project root (folder above dev/)
local last = nil
local function readfile(p) local f=io.open(p,"rb"); if not f then return nil end local s=f:read("*a"); f:close(); return s end
local function writefile(p,s) local f=io.open(p,"wb"); if f then f:write(s); f:close() end end
writefile(dir.."out.txt","bridge started "..os.date().."\n")
local function loop()
  local s = readfile(dir.."cmd.lua")
  if s then
    local id = s:match("^[^\n]*")
    if id ~= last then
      last = id
      local out = {}
      local env = setmetatable({print=function(...) local t={} for i=1,select("#",...) do t[#t+1]=tostring(select(i,...)) end out[#out+1]=table.concat(t,"\t") end}, {__index=_G})
      local fn, err = load(s, "cmd", "t", env)
      local ok, e = false, err
      if fn then ok, e = pcall(fn) end
      writefile(dir.."out.txt", id.."\n"..(ok and "OK" or ("ERR "..tostring(e))).."\n"..table.concat(out,"\n").."\n")
    end
  end
  reaper.defer(loop)
end
loop()
