-- copy every kit script + lib (repo scripts/) and icons (repo icons/) into
-- REAPER/Scripts/Inference Review and Presentation and register new ones
local src = IRP_ROOT .. "scripts/"
local isrc = IRP_ROOT .. "icons/"
local dst = reaper.GetResourcePath() .. "/Scripts/Inference Review and Presentation/"
reaper.RecursiveCreateDirectory(dst .. "lib", 0)
local function copy(a, b) local f = io.open(a, "rb"); if not f then return false end local s = f:read("*a"); f:close(); local g = io.open(b, "wb"); g:write(s); g:close(); return true end
copy(src .. "lib/inference_review_lib.lua", dst .. "lib/inference_review_lib.lua")
print("lib", loadfile(dst .. "lib/inference_review_lib.lua") and "ok" or "SYNTAX ERR")
local registered = {}
local kb = io.open(reaper.GetResourcePath() .. "/reaper-kb.ini"); local kbs = kb and kb:read("*a") or ""; if kb then kb:close() end
local i = 0
IDS = {}
while true do
  local fn = reaper.EnumerateFiles(src, i); if not fn then break end
  if fn:match("^Inference Review and Presentation %- .*%.lua$") then
    copy(src .. fn, dst .. fn)
    local f, e = loadfile(dst .. fn)
    local id = reaper.AddRemoveReaScript(true, 0, dst .. fn, true)
    IDS[fn:match("Inference Review and Presentation %- (.-)%.lua")] = id
    print(f and "ok " or "ERR", fn, e or "", reaper.ReverseNamedCommandLookup(id))
  end
  i = i + 1
end
-- icons folder (used by "Create toolbar file")
for _, sub in ipairs({ "", "150/", "200/" }) do
  reaper.RecursiveCreateDirectory(dst .. "icons/" .. sub, 0)
  local k = 0
  while true do
    local fn = reaper.EnumerateFiles(isrc .. sub, k); if not fn then break end
    copy(isrc .. sub .. fn, dst .. "icons/" .. sub .. fn); k = k + 1
  end
end
print("icons copied")

INSTALLED_DIR = dst
