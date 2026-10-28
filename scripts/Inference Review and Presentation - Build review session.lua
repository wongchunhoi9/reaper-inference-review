-- Inference Review and Presentation - Build review session
-- Adds PROMPT, REF, config tracks and FINDINGS to the current project, coloured,
-- laid out and height-locked. Run once on an empty project (or at the end of one).
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")

local ok, csv = reaper.GetUserInputs("Inference Review and Presentation - Build review session", 2,
  "Config tracks (not counting REF),Config names (separate with ;),extrawidth=300", "7,")
if not ok then return end
local n, names = csv:match("^([^,]*),(.*)$")
n = tonumber(n) or 7
local given = {}
for nm in (names or ""):gmatch("[^;]+") do
  nm = nm:match("^%s*(.-)%s*$")
  if nm ~= "" then given[#given + 1] = nm end
end
if #given > n then n = #given end

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
local proj = 0
local function add(name, role, color)
  local idx = reaper.CountTracks(proj)
  reaper.InsertTrackAtIndex(idx, true)
  local tr = reaper.GetTrack(proj, idx)
  reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", name, true)
  T.apply_role(tr, role)
  if color then reaper.SetTrackColor(tr, T.native(color)) end
  return tr
end

add("PROMPT", "prompt", T.palette.blue)
local ref = add("REF · reference", "ref", T.palette.grey)
local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local firstcfg
for i = 1, n do
  local nm = given[i] or (letters:sub(i, i) .. " · config")
  local tr = add(nm, "config", T.config_colors[((i - 1) % #T.config_colors) + 1])
  firstcfg = firstcfg or tr
end
add("FINDINGS", "findings", T.palette.orange)
-- visual spacer between REF and the first config (REAPER 7 track spacer)
if firstcfg then reaper.SetMediaTrackInfo_Value(firstcfg, "I_SPACER", 1) end

reaper.PreventUIRefresh(-1)
reaper.TrackList_AdjustWindows(false)
reaper.Undo_EndBlock("Inference Review and Presentation: build review session", -1)

-- size everything to the window
dofile(dir .. "Inference Review and Presentation - Fit tracks to window.lua")
