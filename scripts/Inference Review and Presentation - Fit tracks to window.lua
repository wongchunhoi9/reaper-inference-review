-- Inference Review and Presentation - Fit tracks to window
-- Sizes PROMPT / config / FINDINGS lanes to fill the arrange view (proportions 70 : 85 each : 60)
-- and locks their heights. Run again after resizing the window or adding tracks.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")

local proj = 0
local list = T.tracks_with_roles(proj)
if #list == 0 then T.msg("No Inference Review and Presentation tracks found.\nRun 'Inference Review and Presentation - Build review session' or 'Set selected tracks as config / note lane' first.") return end
local H = T.arrange_height()
if not H or H < 100 then T.msg("Could not read the window height.") return end

-- visible tracks only; spacers take a fixed amount of room
local weight, spacers = 0, 0
local spacer_px = 0
for _, t in ipairs(list) do
  if reaper.IsTrackVisible(t.tr, false) then
    weight = weight + (t.role == "prompt" and T.H.prompt or t.role == "findings" and T.H.findings or T.is_note_role(t.role) and T.H.findings or T.H.config)
    if reaper.GetMediaTrackInfo_Value(t.tr, "I_SPACER") > 0 then spacers = spacers + 1 end
  end
end
-- measure one spacer: REAPER draws it above the track; read it from track Y positions
for _, t in ipairs(list) do
  if reaper.GetMediaTrackInfo_Value(t.tr, "I_SPACER") > 0 and t.idx > 0 then
    local prev = reaper.GetTrack(proj, t.idx - 1)
    local gap = reaper.GetMediaTrackInfo_Value(t.tr, "I_TCPY") - (reaper.GetMediaTrackInfo_Value(prev, "I_TCPY") + reaper.GetMediaTrackInfo_Value(prev, "I_WNDH"))
    if gap > 0 then spacer_px = gap end
    break
  end
end
-- other (non-review) visible tracks keep their height
local other = 0
for i = 0, reaper.CountTracks(proj) - 1 do
  local tr = reaper.GetTrack(proj, i)
  if T.get_role(tr) == "" and reaper.IsTrackVisible(tr, false) then other = other + reaper.GetMediaTrackInfo_Value(tr, "I_WNDH") end
end
local avail = H - spacers * spacer_px - other - 2
local k = avail / weight

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
for _, t in ipairs(list) do
  local w = (t.role == "prompt" and T.H.prompt) or (T.is_note_role(t.role) and T.H.findings) or T.H.config
  T.set_height(t.tr, math.floor(w * k), true)
end
reaper.PreventUIRefresh(-1)
reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
reaper.Undo_EndBlock("Inference Review and Presentation: fit tracks to window", -1)
