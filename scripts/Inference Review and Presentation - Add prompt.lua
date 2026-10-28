-- Inference Review and Presentation - Add prompt
-- Toolbar button: + Prompt & Region lane 1 · Region P01, P02 ... in ruler lane 1 plus note items on PROMPT and FINDINGS.
-- Needs: time selection (or uses 5 s at the edit cursor).
-- Makes a region over the time selection (or 5 s at the edit cursor) named P01, P02 ...
-- and adds empty note items (stretched text) on the PROMPT and FINDINGS lanes.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

local proj = 0
local s, e = T.time_range()
local count = 0
local i = 0
while true do
  local rv, isrgn = reaper.EnumProjectMarkers(i)
  if rv == 0 then break end
  if isrgn then count = count + 1 end
  i = i + 1
end
local def = string.format("P%02d", count + 1)
local ok, csv = reaper.GetUserInputs("Inference Review and Presentation - Add prompt", 2, "Region name,Prompt text,extrawidth=320", def .. ",")
if not ok then return end
local name, text = csv:match("^([^,]*),(.*)$")

reaper.Undo_BeginBlock()
T.add_region(s, e, name ~= "" and name or def, T.native(T.palette.blue), 0) -- lane 1 = prompts
for _, t in ipairs(T.tracks_with_roles(proj)) do
  if t.role == "prompt" then T.add_note_item(t.tr, s, e - s, (name ~= "" and name or def) .. "\n" .. (text or "")) end
  if t.role == "findings" then T.add_note_item(t.tr, s, e - s, "…") end
end
reaper.UpdateArrange()
reaper.Undo_EndBlock("Inference Review and Presentation: add prompt", -1)
