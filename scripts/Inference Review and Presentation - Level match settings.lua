-- Inference Review and Presentation - Level match settings
-- Toolbar button: Level match settings · Target (match REF, or a fixed LUFS-I), fallback level and boost limit; re-measures if level matching is on.
-- Needs: nothing. Run it again after new renders to re-measure.
-- Settings are saved in the project.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end
local LM = dofile(dir .. "lib/level_match.lua")(T)

local st = LM.settings()
local ok, csv = reaper.GetUserInputs("Inference Review and Presentation - Level match settings", 3,
  "Match to (REF or FIXED),Target / fallback LUFS-I,Max boost (dB),extrawidth=80",
  (st.mode == "ref" and "REF" or "FIXED") .. "," .. st.target .. "," .. st.max_boost)
if not ok then return end
local mode, target, boost = csv:match("^%s*(%a+)%s*,%s*([%-%d%.]+)%s*,%s*([%d%.]+)%s*$")
mode = mode and mode:lower()
target, boost = tonumber(target), tonumber(boost)
if not (mode == "ref" or mode == "fixed") or not target or not boost or target > 0 or target < -60 then
  T.msg("Not changed. Use:\n  Match to: REF or FIXED\n  Target: a LUFS value such as -23 (or -16)\n  Max boost: dB, e.g. 12")
  return
end
LM.save_settings({ mode = mode, target = target, max_boost = boost })
if LM.is_on() then
  T.msg(LM.apply())
else
  T.msg("Saved. " .. (mode == "ref" and ("Configs will match REF in each prompt; " .. target .. " LUFS-I where a prompt has no REF.")
    or ("Every take, REF included, will go to " .. target .. " LUFS-I.")) .. "\nTurn on with 'Level match ON/OFF'.")
end
