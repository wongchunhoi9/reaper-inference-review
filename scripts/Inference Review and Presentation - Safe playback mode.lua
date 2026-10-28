-- Inference Review and Presentation - Safe playback mode (toggle)
-- Toolbar button: Safe playback ON/OFF · Toggle (yellow = ON). While ON only one of REF / configs plays; click a name to switch.
-- Needs: nothing (turn it on before presenting).
-- While ON (toolbar button lit):
--  * only ONE of REF / configs is ever audible (exclusive solo in place);
--  * click a config's name (select it) to switch to it instantly, playback keeps running;
--  * soloing another track with its S button also switches; un-soloing everything falls back to the last one;
--  * note lanes never play (no output);
--  * exception: while the A/B window's crossfader is in use, A and B both play.
-- Run again (or press the button) to turn it off.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

if reaper.set_action_options then reaper.set_action_options(1 | 4) end -- re-run = turn off; set toggle state
local _, _, sec, cmd = reaper.get_action_context()
reaper.SetToggleCommandState(sec, cmd, 1)
reaper.RefreshToolbar2(sec, cmd)

local last_sel, last_solo = nil, {}
local function first_selected_config()
  for i = 0, reaper.CountSelectedTracks(0) - 1 do
    local tr = reaper.GetSelectedTrack(0, i)
    if T.is_config_role(T.get_role(tr)) then return tr end
  end
end

-- start: something must be audible but only one thing
do
  local list = T.config_tracks(0)
  if #list > 0 then
    local start = first_selected_config() or T.get_active()
    if not start then for _, t in ipairs(list) do if reaper.GetMediaTrackInfo_Value(t, "I_SOLO") > 0 then start = t break end end end
    T.set_active(start or list[1])
    last_sel = start or list[1]
  end
end

local function tick()
  local list = T.config_tracks(0)
  -- While the A/B window's crossfader is in use, A and B are both soloed on purpose: don't interfere.
  local xfading = reaper.GetExtState(T.EXT, "xfade") == "1"
  if xfading then last_solo = {} end
  if #list > 0 and not xfading then
    local active = T.get_active()
    -- 1) selection change -> audition the newly selected config
    local sel = first_selected_config()
    if sel and sel ~= last_sel and sel ~= active then
      T.set_active(sel, true); active = sel
    end
    last_sel = sel or last_sel
    -- 2) solo buttons: a newly soloed config wins; more than one -> keep the newest
    local soloed, newest = {}, nil
    for _, t in ipairs(list) do
      local on = reaper.GetMediaTrackInfo_Value(t, "I_SOLO") ~= 0
      if on then soloed[#soloed + 1] = t; if not last_solo[t] then newest = t end end
    end
    if newest and newest ~= active then T.set_active(newest); active = newest; last_sel = newest
    elseif #soloed > 1 or #soloed == 0 then
      T.set_active(active or list[1], true)
    end
    last_solo = {}
    for _, t in ipairs(list) do if reaper.GetMediaTrackInfo_Value(t, "I_SOLO") ~= 0 then last_solo[t] = true end end
  end
  reaper.defer(tick)
end

reaper.atexit(function()
  reaper.SetToggleCommandState(sec, cmd, 0)
  reaper.RefreshToolbar2(sec, cmd)
end)
tick()
