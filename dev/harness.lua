-- run a kit script with faked dialogs. usage: RUNKIT(name, {answers...}); messages go to LOG.
-- Runs the script straight from the repo's scripts/ folder. Set _G.RUNKIT_DIR to run another copy instead
-- (e.g. the installed one, needed for "Create toolbar file", which looks for icons/ next to itself).
local real = { gac = reaper.get_action_context, gui = reaper.GetUserInputs, smb = reaper.ShowMessageBox, cmd = reaper.Main_OnCommand }
LOG = LOG or {}
function RUNKIT(name, inputs)
  local path = (RUNKIT_DIR or (IRP_ROOT .. "scripts/")) .. name .. ".lua"
  local qi = 1
  reaper.get_action_context = function() return false, path, 0, 0, 0, 0, 0 end
  reaper.GetUserInputs = function(title, n, caps, def) local a = inputs and inputs[qi]; qi = qi + 1; LOG[#LOG+1] = "input: " .. title .. " -> " .. tostring(a); if a == nil then return false, "" end return true, a end
  reaper.ShowMessageBox = function(m, t, f) LOG[#LOG+1] = "message: " .. m; return 1 end
  reaper.Main_OnCommand = function(id, f) if id == 40850 then LOG[#LOG+1] = "(would open notes window)"; return end return real.cmd(id, f) end
  local ok, err = pcall(dofile, path)
  reaper.get_action_context, reaper.GetUserInputs, reaper.ShowMessageBox, reaper.Main_OnCommand = real.gac, real.gui, real.smb, real.cmd
  if not ok then LOG[#LOG+1] = "ERROR: " .. tostring(err) end
  return ok
end
