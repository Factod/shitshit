-- Z-City integration for [G]VRMod: Ultimate.
--
-- Quest/Touch controllers expose the thumb rest as a capacitive touch input, not
-- as a physical click.  Ultimate's stock Touch profile leaves each thumb rest
-- unused and uses touching both of them as a reload chord.  Z-City uses the
-- regular +attack/+reload commands, so give those inputs their normal actions:
-- right thumb rest fires and left thumb rest reloads.

if SERVER then
	AddCSLuaFile()
	return
end

local PROFILE_PATH = "vrmod/vrmod_bindings_oculus_touch.txt"
local LEFT_THUMBREST = "/user/hand/left/input/thumbrest"
local RIGHT_THUMBREST = "/user/hand/right/input/thumbrest"
local RELOAD_ACTION = "/actions/main/in/boolean_reload"
local FIRE_ACTION = "/actions/main/in/boolean_primaryfire"

local enabled = CreateClientConVar(
	"zcity_vrmod_thumbrest_controls",
	"1",
	true,
	false,
	"Map [G]VRMod: Ultimate Touch thumb rests in Z-City: right fires, left reloads.",
	0,
	1
)

local function isThumbrestReloadChord(chord)
	if not istable(chord) or chord.output ~= RELOAD_ACTION or not istable(chord.inputs) then
		return false
	end

	local left, right = false, false
	for _, input in ipairs(chord.inputs) do
		if not istable(input) then continue end

		if input[1] == LEFT_THUMBREST and input[2] == "touch" then
			left = true
		elseif input[1] == RIGHT_THUMBREST and input[2] == "touch" then
			right = true
		end
	end

	return left and right
end

local function setThumbrestAction(sources, path, action)
	for _, source in ipairs(sources) do
		if source.path == path then
			source.mode = "button"
			source.parameters = source.parameters or {}
			source.inputs = {
				touch = {
					output = action
				}
			}
			return true
		end
	end

	return false
end

local originalTouchBindings
local patchedTouchBindings

local function patchTouchBindings()
	if not enabled:GetBool() or not g_VR or not isstring(g_VR.bindings_touch) then
		return false
	end

	-- Keep the untouched Ultimate profile so disabling this convar puts the
	-- player's default binding back exactly as VRMod supplied it.
	if g_VR.bindings_touch ~= patchedTouchBindings then
		originalTouchBindings = g_VR.bindings_touch
	end

	local bindings = util.JSONToTable(g_VR.bindings_touch)
	local main = bindings and bindings.bindings and bindings.bindings["/actions/main"]
	if not istable(main) or not istable(main.sources) then
		return false
	end

	-- The default profile maps a simultaneous touch on both rests to reload.
	-- Remove only that exact chord; unrelated user/profile chords are retained.
	if istable(main.chords) then
		for index = #main.chords, 1, -1 do
			if isThumbrestReloadChord(main.chords[index]) then
				table.remove(main.chords, index)
			end
		end
	end

	local leftPatched = setThumbrestAction(main.sources, LEFT_THUMBREST, RELOAD_ACTION)
	local rightPatched = setThumbrestAction(main.sources, RIGHT_THUMBREST, FIRE_ACTION)
	if not leftPatched or not rightPatched then
		return false
	end

	local encoded = util.TableToJSON(bindings, true)
	if not isstring(encoded) then
		return false
	end

	-- Keep VRMod's in-memory default and its data-file default in sync.  The
	-- latter is what SteamVR reads when VRMod starts its action manifest.
	patchedTouchBindings = encoded
	if g_VR.bindings_touch ~= encoded then
		g_VR.bindings_touch = encoded
		file.Write(PROFILE_PATH, encoded)
		return true
	end

	return false
end

local function restoreTouchBindings()
	if not originalTouchBindings or not g_VR then return end

	g_VR.bindings_touch = originalTouchBindings
	file.Write(PROFILE_PATH, originalTouchBindings)
	patchedTouchBindings = nil
end

cvars.AddChangeCallback("zcity_vrmod_thumbrest_controls", function(_, _, value)
	if tobool(value) then
		patchTouchBindings()
	else
		restoreTouchBindings()
	end
end, "ZCityVRModThumbrestBindings")

-- VRMod writes its default bindings while it loads.  Its autorun order is not
-- guaranteed relative to Z-City, so retry briefly until that profile exists.
local nextAttempt = 0
hook.Add("Think", "ZCityVRModThumbrestBindings", function()
	if CurTime() < nextAttempt or not enabled:GetBool() then return end
	nextAttempt = CurTime() + 1

	-- Once the current profile is patched, there is no need to decode JSON every
	-- second. A VRMod reload replaces the string and causes it to be patched again.
	if g_VR and g_VR.bindings_touch == patchedTouchBindings then return end

	patchTouchBindings()
end)

-- A VRMod reset rewrites every default binding file.  Deferring one tick lets
-- VRMod finish that write before this compatibility profile is restored.
hook.Add("VRMod_Reset", "ZCityVRModThumbrestBindings", function()
	timer.Simple(0, patchTouchBindings)
end)
