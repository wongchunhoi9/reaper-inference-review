-- Inference Review and Presentation - Create toolbar file
-- 1) Copies the coloured button icons (icons/ next to this script) into REAPER's toolbar icon folder.
-- 2) Writes 'Inference Review and Presentation toolbar.ReaperMenu' next to this script, using this computer's action IDs.
-- Then: Options > Customize menus/toolbars > Floating toolbar 16 > Import/Export > Import > that file > OK.
-- Colours: grey = setup, blue = notes/markers, yellow = playback, orange = output.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")

local buttons = {
  { "Build review session", "Build session", "build" },
  { "Set selected tracks as config", "Set config", "config" },
  { "Set selected tracks as note", "Set note lane", "notelane" },
  { "Fit tracks to window", "Fit to window", "fit" },
  { "Toggle height lock on selected tracks", "Lock height", "lock" },
  "-",
  { "Add prompt", "+ Prompt", "prompt" },
  { "Add region lane 2", "+ Region lane 2", "region2" },
  { "Add note item", "+ Note", "note" },
  { "Add take marker", "+ Marker", "marker" },
  { "Refresh take marker colours", "Marker colour", "markercol" },
  "-",
  { "Safe playback mode", "Safe playback", "safeplay" },
  { "Solo previous config", "◀ Previous", "prev" },
  { "Solo next config", "Next ▶", "next" },
  { "A-B swap", "A/B swap", "abswap" },
  "-",
  { "Export findings", "Export findings", "export" },
  { "Theme settings", "Settings", "settings" },
}

-- 1) icons
local function copy(a, b)
  local f = io.open(a, "rb"); if not f then return false end
  local s = f:read("*a"); f:close()
  local g = io.open(b, "wb"); if not g then return false end
  g:write(s); g:close(); return true
end
local icondst = reaper.GetResourcePath() .. "/Data/toolbar_icons/"
local copied = 0
for _, sub in ipairs({ "", "150/", "200/" }) do
  reaper.RecursiveCreateDirectory(icondst .. sub, 0)
  for _, b in ipairs(buttons) do
    if type(b) == "table" and copy(dir .. "icons/" .. sub .. "irp_" .. b[3] .. ".png", icondst .. sub .. "irp_" .. b[3] .. ".png") then copied = copied + 1 end
  end
end

-- 2) action IDs from reaper-kb.ini
local ids = {}
local f = io.open(reaper.GetResourcePath() .. "/reaper-kb.ini", "r")
if f then
  for line in f:lines() do
    local id, file = line:match('^SCR %d+ 0 (%S+) ".-" "(.-)"%s*$')
    if id and file then
      local nm = file:match("Inference Review and Presentation %- (.-)%.lua$")
      if nm then ids[nm] = "_" .. id end
    end
  end
  f:close()
end

local out, missing, n = { "[Floating toolbar 16]", "title=Inference Review and Presentation" }, {}, 0
for _, b in ipairs(buttons) do
  if b == "-" then
    out[#out + 1] = "item_" .. n .. "=-1"; n = n + 1
  elseif ids[b[1]] then
    out[#out + 1] = "icon_" .. n .. "=" .. (copied > 0 and ("irp_" .. b[3] .. ".png") or "text_wide")
    out[#out + 1] = "item_" .. n .. "=" .. ids[b[1]] .. " " .. b[2]
    n = n + 1
  else
    missing[#missing + 1] = b[1]
  end
end
local path = dir .. "Inference Review and Presentation toolbar.ReaperMenu"
local g = io.open(path, "w")
if not g then T.msg("Could not write " .. path) return end
g:write(table.concat(out, "\n") .. "\n"); g:close()
T.msg("Toolbar file written:\n" .. path .. "\n\nIcons installed: " .. copied ..
  (#missing > 0 and ("\n\nNot in the action list yet (load them first):\n- " .. table.concat(missing, "\n- ")) or "") ..
  "\n\nImport: Options > Customize menus/toolbars > pick 'Floating toolbar 16' > Import/Export > Import.\nShow it: View > Toolbars > Toolbar 16 (right-click it to dock).")
