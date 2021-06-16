# radio
Radio used with pma-voice


You will have to change the core name to your core so from PSCore to QBCore example.

Note that this is currently using sligtly older version of pma-voice

You will also have to rename the exports from ps-voice to pma-voice or the name of the voip script.


add this export function to pma-voice/client/main.lua
Highly recommending to remove command for setting voulume because its broken in v3.3.0 version


function setRadioVolume(value)
    radioVolume = value
	if radioVolume >= 1.0 then
		radioVolume = 1.0
	end
	if radioVolume <= 0.1 then
		radioVolume = 0.1
	end
end
exports("setRadioVolume", setRadioVolume)

then add this function

function getRadioVolume()
    return radioVolume
end
exports("getRadioVolume", getRadioVolume)

