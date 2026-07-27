-- Z-City integration for [G]VRMod: Ultimate.
--
-- Ultimate's Oculus Touch profile emits boolean_reload when both capacitive
-- thumb rests are touched. Keep all of its other controls (especially primary
-- fire on the right trigger) unchanged and forward only reload to Z-City.

if SERVER then
	AddCSLuaFile()
	return
end

local enabled = CreateClientConVar(
	"zcity_vrmod_thumbrest_reload",
	"1",
	true,
	false,
	"Forward [G]VRMod: Ultimate's thumb-rest reload action to Z-City.",
	0,
	1
)

local RELOAD_ACTION = "boolean_reload"

-- Handle the VR reload action here rather than letting Ultimate's generic
-- command handler do it. This keeps the normal UserCmd reload path used by
-- Z-City weapons while deliberately leaving every fire action to VRMod.
hook.Add("VRMod_AllowDefaultAction", "ZCityVRModThumbrestReload", function(action)
	if enabled:GetBool() and action == RELOAD_ACTION then
		return false
	end
end)

hook.Add("VRMod_Input", "ZCityVRModThumbrestReload", function(action, pressed)
	if not enabled:GetBool() or action ~= RELOAD_ACTION then return end

	LocalPlayer():ConCommand(pressed and "+reload" or "-reload")
end)
