-- Install Inference Review and Presentation
-- One-step install (and update) of the whole kit. Run it from the unzipped release folder:
--   Actions > Show action list > New action > Load ReaScript > pick this file > Run.
-- What it does:
--   1) Copies Scripts/Inference Review and Presentation (scripts, lib, icons) into REAPER's Scripts folder
--      and adds every kit script to the action list.
--   2) Copies the theme into REAPER's ColorThemes folder and switches to it.
--   3) Sets up Floating toolbar 16 (Session, Annotate) and Floating toolbar 15 (Playback, Output), and puts two
--      logo buttons on the Main toolbar that open / close them. This edits reaper-menu.ini (a backup is made the
--      first time), so REAPER has to be restarted before the toolbars appear.
-- Safe to run again: it updates the files and doesn't add buttons twice.
local NAME = "Inference Review and Presentation"
local THEME = "Inference_Review_and_Presentation.ReaperThemeZip"
local here = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local res = reaper.GetResourcePath() .. "/"
local src = here .. "Scripts/" .. NAME .. "/"
local dst = res .. "Scripts/" .. NAME .. "/"

local function msg(s, kind) return reaper.ShowMessageBox(s, NAME .. " installer", kind or 0) end
local function rd(p) local f = io.open(p, "rb"); if not f then return nil end local s = f:read("*a"); f:close(); return s end
local function wr(p, s) local f = io.open(p, "wb"); if not f then return false end f:write(s); f:close(); return true end

if not reaper.file_exists(src .. "lib/inference_review_lib.lua") then
  msg("Run this from the unzipped release folder: the folder 'Scripts/" .. NAME .. "' must be next to this file.") return
end
local T = dofile(src .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

-- 1) scripts, lib and icons, then the action list
local failed = {}
local function copy_tree(a, b)
  reaper.RecursiveCreateDirectory(b, 0)
  local i = 0
  while true do
    local fn = reaper.EnumerateFiles(a, i); if not fn then break end
    if not fn:match("^%.") then
      local s = rd(a .. fn)
      if not (s and wr(b .. fn, s)) then failed[#failed + 1] = b .. fn end
    end
    i = i + 1
  end
  i = 0
  while true do
    local d = reaper.EnumerateSubdirectories(a, i); if not d then break end
    copy_tree(a .. d .. "/", b .. d .. "/"); i = i + 1
  end
end
copy_tree(src, dst)
if #failed > 0 then msg("Could not copy:\n" .. table.concat(failed, "\n") .. "\n\nNothing else was changed.") return end

local n, i = 0, 0
while true do
  local fn = reaper.EnumerateFiles(src, i); if not fn then break end
  if fn:sub(1, #NAME + 3) == NAME .. " - " and fn:match("%.lua$") then
    reaper.AddRemoveReaScript(true, 0, dst .. fn, true); n = n + 1
  end
  i = i + 1
end
-- scripts renamed in later versions: remove the old action and file
for _, old in ipairs({ "Build review session" }) do -- 1.1.0: now "Initiate session"
  local p = dst .. NAME .. " - " .. old .. ".lua"
  if reaper.file_exists(p) then reaper.AddRemoveReaScript(false, 0, p, true); os.remove(p) end
end

-- 2) theme
local theme_ok = false
local tz = rd(here .. THEME)
if tz then
  reaper.RecursiveCreateDirectory(res .. "ColorThemes", 0)
  theme_ok = wr(res .. "ColorThemes/" .. THEME, tz) and reaper.OpenColorThemeFile(res .. "ColorThemes/" .. THEME)
end

-- 3) toolbars: "Create toolbar file" writes the toolbar set into MenuSets; merge it into reaper-menu.ini
IRP_INSTALL = { dir = dst }
dofile(dst .. NAME .. " - Create toolbar file.lua")
local info = IRP_INSTALL
IRP_INSTALL = nil
if not info.set then msg("Scripts and theme are installed, but the toolbar files could not be written.") return end

-- reaper-menu.ini as a list of sections { name, lines }
local function parse(t)
  local secs, cur = {}, nil
  for line in (t .. "\n"):gmatch("(.-)\r?\n") do
    local name = line:match("^%[(.+)%]$")
    if name then cur = { name = name, lines = {} }; secs[#secs + 1] = cur
    elseif cur and line ~= "" then cur.lines[#cur.lines + 1] = line end
  end
  return secs
end
local ini = res .. "reaper-menu.ini"
local text = rd(ini) or ""          -- no file = the user never customised a menu or toolbar
local nl = text:find("\r\n") and "\r\n" or "\n"
local secs = parse(text)
local function find(name) for k, s in ipairs(secs) do if s.name == name then return s, k end end end

-- toolbars 16 and 15: replace; ask first if one of them holds someone else's toolbar
local skipped = {}
for _, s in ipairs(parse(rd(info.set) or "")) do
  local old, k = find(s.name)
  local title = ""
  for _, l in ipairs(old and old.lines or {}) do title = l:match("^title=(.*)") or title end
  if not old then
    secs[#secs + 1] = s
  elseif title:sub(1, 16) == "Inference Review" or msg(s.name .. " already holds another toolbar" ..
      (title ~= "" and (" (\"" .. title .. "\")") or "") .. ".\n\nReplace it with the kit's toolbar?", 4) == 6 then
    secs[k] = s
  else
    skipped[s.name] = true
  end
end

-- Main toolbar: add the two logo buttons. A user who never changed the Main toolbar has no section for it, and
-- writing one with only our buttons would hide REAPER's own buttons, so start from REAPER's default list.
-- shortcut: default list exported from REAPER 7.83; other 7.x versions may differ slightly, update it when REAPER changes it.
local DEFAULT_MAIN = {
  "item_0=40023 New project...", "item_1=40025 Open project...", "item_2=40026 Save project",
  "item_3=40021 Project settings...", "item_4=40029 Undo", "item_5=40030 Redo", "item_6=40364 Enable metronome",
  "item_7=42616 Marquee selection", "item_8=-1", "item_9=40041 Enable auto-crossfade",
  "item_10=1156 Enable item and track media/razor edit grouping", "item_11=1162 Toggle ripple editing",
  "item_12=40070 Move envelope points with media items", "item_13=40145 Show arrange view grid",
  "item_14=1157 Enable snapping", "item_15=1135 Enable locking", "item_16=42618 Razor editing",
  "tbf_7=1", "tbf_11=1", "tbf_16=1",
}
local LOGOS = { -- action (Toolbar: Open/close toolbar N), icon, tooltip, toolbar it opens
  { "41943", "irp_logo16.png", "Inference Review: show / hide toolbar 16 (Session & Annotate)", "Floating toolbar 16" },
  { "41942", "irp_logo15.png", "Inference Review: show / hide toolbar 15 (Playback & Output)", "Floating toolbar 15" },
}
local main = find("Main toolbar")
if not main then main = { name = "Main toolbar", lines = { table.unpack(DEFAULT_MAIN) } }; secs[#secs + 1] = main end
local last = -1
for _, l in ipairs(main.lines) do last = math.max(last, tonumber(l:match("^item_(%d+)=")) or -1) end
for _, b in ipairs(LOGOS) do
  if not skipped[b[4]] then
    local pos -- the button may already be there (added by hand, or by an earlier install)
    for _, l in ipairs(main.lines) do pos = pos or l:match("^item_(%d+)=" .. b[1] .. "%f[%D]") end
    if not pos then last = last + 1; pos = tostring(last); main.lines[#main.lines + 1] = "item_" .. pos .. "=" .. b[1] .. " " .. b[3] end
    for k = #main.lines, 1, -1 do if main.lines[k]:match("^icon_" .. pos .. "=") then table.remove(main.lines, k) end end
    main.lines[#main.lines + 1] = "icon_" .. pos .. "=" .. b[2]
  end
end

-- keep the user's original menus once, then write
local bak = ini .. ".before-inference-review"
if text ~= "" and not reaper.file_exists(bak) then wr(bak, text) end
local out = {}
for _, s in ipairs(secs) do
  out[#out + 1] = "[" .. s.name .. "]"
  for _, l in ipairs(s.lines) do out[#out + 1] = l end
end
if not wr(ini, table.concat(out, nl) .. nl) then msg("Scripts and theme are installed, but " .. ini .. " could not be written.") return end

local sk = {}
for name in pairs(skipped) do sk[#sk + 1] = name end
msg("Installed version " .. T.VERSION .. ":\n" ..
  "- " .. n .. " scripts added to the action list\n" ..
  "- theme: " .. (theme_ok and "installed and switched on" or ("not found next to the installer (" .. THEME .. ")")) .. "\n" ..
  "- toolbars 16 and 15, plus two logo buttons on the Main toolbar" ..
  (#sk > 0 and ("\n  (kept your own " .. table.concat(sk, " and ") .. "; to use the kit toolbar elsewhere, import its .ReaperMenu file from " .. res .. "MenuSets)") or "") ..
  (#info.missing > 0 and ("\n\nNot in the action list (buttons left out):\n- " .. table.concat(info.missing, "\n- ")) or "") ..
  "\n\nNOW QUIT AND REOPEN REAPER so the toolbars appear (until then, don't open Customize menus/toolbars)." ..
  "\n\nThen click the two logo buttons at the end of the Main toolbar: grey/blue = toolbar 16 (Session, Annotate), " ..
  "yellow/orange = toolbar 15 (Playback, Output). Right-click a toolbar to dock it; dock 15 under 16." ..
  (reaper.file_exists(bak) and ("\n\nYour menus before the install: " .. bak) or ""))
