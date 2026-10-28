local function st(tag)
  local t = {}
  for i = 0, reaper.CountTracks(0) - 1 do local tr = reaper.GetTrack(0, i); if reaper.GetMediaTrackInfo_Value(tr, "I_SOLO") ~= 0 then local _, n = reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", "", false); t[#t + 1] = n end end
  print(tag, "soloed: [" .. table.concat(t, " | ") .. "]", "toggle=" .. reaper.GetToggleCommandState(reaper.NamedCommandLookup("_RS6e545d8e0b20a20ac3de4778a042aab7b9e8075d")))
end
return st
