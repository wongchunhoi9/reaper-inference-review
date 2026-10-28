-- Inference Review and Presentation - Create toolbar file
-- Makes the kit's two toolbars, using this computer's action IDs:
--   Toolbar 16 = Session (grey) + Annotate (blue)
--   Toolbar 15 = Playback (yellow) + Output (orange)
-- 1) Copies the coloured button icons (icons/ next to this script) into REAPER's toolbar icon folder.
-- 2) Writes two .ReaperMenu files next to this script.
-- Then: Options > Customize menus/toolbars > pick 'Floating toolbar 16' > Import/Export > Import > the "toolbar 16" file,
--       then the same for 'Floating toolbar 15' with the "toolbar 15" file > OK.
-- Hovering a button shows its tooltip: what it does, what it needs, and the script name (to find it in the action list).
-- Needs: the kit scripts loaded in the action list.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

-- One row per button: script name (after "Inference Review and Presentation - "), button label, icon key,
-- what it does, what it needs. The tooltip is built from these (REAPER shows the item text as tooltip on image buttons).
-- Keep the same texts in each script's header and in the README table.
local toolbars = {
  { section = "Floating toolbar 16", title = "Inference Review - Session & Annotate", file = "toolbar 16 (Session, Annotate)",
    buttons = {
      { "Initiate session", "Initiate session", "build",
        "Adds PROMPT, REF, config lanes and FINDINGS, coloured, laid out and height-locked.",
        "an empty project (asks how many configs)" },
      { "Set selected tracks as config", "Set config lane", "config",
        "Makes tracks config lanes: Review layout with fader, meter, M/S and normal output.",
        "selected track(s)" },
      { "Set selected tracks as note", "Set note lane", "notelane",
        "Makes tracks note lanes: name only, no audio output.",
        "selected track(s)" },
      { "Fit tracks to window", "Fit to window", "fit",
        "Resizes all review lanes to fill the arrange view and locks their heights.",
        "nothing (run again after resizing the window)" },
      { "Toggle height lock on selected tracks", "Lock height", "lock",
        "Locks or unlocks the height of the selected tracks.",
        "selected track(s)" },
      "-",
      { "Add prompt", "+ Prompt & Region lane 1", "prompt",
        "Region P01, P02 ... in ruler lane 1 plus note items on PROMPT and FINDINGS.",
        "time selection (or uses 5 s at the edit cursor)" },
      { "Add region lane 2", "+ Region lane 2", "region2",
        "Region in ruler lane 2 for rounds, sections or issues.",
        "time selection; REAPER 7.62+" },
      { "Add note item", "+ Note", "note",
        "Note item on the selected track, then opens its notes window.",
        "selected track; time selection (or uses 5 s at the edit cursor)" },
      { "Add take marker", "+ Take marker", "marker",
        "Point marker at the edit cursor, or a duration pair (start / end) over the time selection.",
        "item under the edit cursor on the selected track (or a selected item); optional time selection" },
      { "Refresh take marker colours", "Take marker colour reset", "markercol",
        "Re-picks black or white text for every take marker after colour changes.",
        "nothing" },
    } },
  { section = "Floating toolbar 15", title = "Inference Review - Playback & Output", file = "toolbar 15 (Playback, Output)",
    buttons = {
      { "Safe playback mode", "Safe playback ON/OFF", "safeplay",
        "Toggle (yellow = ON). While ON only one of REF / configs plays; click a name to switch.",
        "nothing (turn it on before presenting)" },
      { "Solo previous config", "◀ Previous", "prev",
        "Solos the previous lane (REF, A, B ...); playback keeps running.",
        "REF / config lanes" },
      { "Solo next config", "Next ▶", "next",
        "Solos the next lane (REF, A, B ...); playback keeps running.",
        "REF / config lanes" },
      { "A-B swap", "A/B swap", "abswap",
        "Flips between the current and the previously heard config.",
        "two configs heard in this session" },
      "-",
      { "Export findings", "Export findings", "export",
        "Writes a Markdown report and a CSV of take markers next to the project file.",
        "saved project" },
      { "Theme settings", "Settings", "settings",
        "Sliders for track name size, name width and compact height.",
        "the Inference_Review_and_Presentation theme active" },
      { "About", "About", "about",
        "Shows the kit version, the theme version actually loaded and the REAPER version, with warnings.",
        "nothing" },
    } },
}

local function tooltip(b)
  return b[2] .. " · " .. b[4] .. " Needs: " .. b[5] .. ". [Inference Review and Presentation - " .. b[1] .. "]"
end

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
  for _, tb in ipairs(toolbars) do
    for _, b in ipairs(tb.buttons) do
      if type(b) == "table" and copy(dir .. "icons/" .. sub .. "irp_" .. b[3] .. ".png", icondst .. sub .. "irp_" .. b[3] .. ".png") then copied = copied + 1 end
    end
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

-- 3) one .ReaperMenu file per toolbar. Without icons, buttons fall back to text with the short label.
os.remove(dir .. "Inference Review and Presentation toolbar.ReaperMenu") -- single-toolbar file from 1.0.0
local written, missing = {}, {}
for _, tb in ipairs(toolbars) do
  local out, n = { "[" .. tb.section .. "]", "title=" .. tb.title }, 0
  for _, b in ipairs(tb.buttons) do
    if b == "-" then
      out[#out + 1] = "item_" .. n .. "=-1"; n = n + 1
    elseif ids[b[1]] then
      if copied > 0 then
        out[#out + 1] = "icon_" .. n .. "=irp_" .. b[3] .. ".png"
        out[#out + 1] = "item_" .. n .. "=" .. ids[b[1]] .. " " .. tooltip(b)
      else
        out[#out + 1] = "icon_" .. n .. "=text_wide"
        out[#out + 1] = "item_" .. n .. "=" .. ids[b[1]] .. " " .. b[2]
      end
      n = n + 1
    else
      missing[#missing + 1] = b[1]
    end
  end
  local path = dir .. "Inference Review and Presentation " .. tb.file .. ".ReaperMenu"
  local g = io.open(path, "w")
  if not g then T.msg("Could not write " .. path) return end
  g:write(table.concat(out, "\n") .. "\n"); g:close()
  written[#written + 1] = path
end

T.msg("Toolbar files written:\n" .. table.concat(written, "\n") .. "\n\nIcons installed: " .. copied ..
  (#missing > 0 and ("\n\nNot in the action list yet (load them first):\n- " .. table.concat(missing, "\n- ")) or "") ..
  "\n\nImport: Options > Customize menus/toolbars > pick 'Floating toolbar 16' > Import/Export > Import > the 'toolbar 16' file." ..
  "\nThen pick 'Floating toolbar 15' and import the 'toolbar 15' file. OK." ..
  "\nShow them: in the action list run 'Toolbar: Open/close toolbar 16' and '... toolbar 15' (right-click a toolbar to dock it; dock 15 under 16).")
