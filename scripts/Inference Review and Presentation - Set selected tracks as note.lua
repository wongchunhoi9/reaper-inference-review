-- Inference Review and Presentation - Set selected tracks as note
-- Toolbar button: Set note lane · Makes tracks note lanes: name only, no audio output.
-- Needs: selected track(s).
-- Note lane: name only (Review Note layout), no audio output (master send off, no hardware outs).
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

local role = "note"
local n = reaper.CountSelectedTracks(0)
if n == 0 then T.msg("Select one or more tracks first.") return end
reaper.Undo_BeginBlock()
for i = 0, n - 1 do
  local tr = reaper.GetSelectedTrack(0, i)
  local r = role
  if role == "note" then
    local _, nm = reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", "", false)
    nm = nm:upper()
    r = nm:find("PROMPT") and "prompt" or nm:find("FINDING") and "findings" or "note"
  end
  T.apply_role(tr, r)
end
reaper.TrackList_AdjustWindows(false)
reaper.Undo_EndBlock("Inference Review and Presentation: set tracks as " .. role, -1)
