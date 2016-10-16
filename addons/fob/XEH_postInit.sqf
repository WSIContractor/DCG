/*
Author:
Nicholas Clark (SENSEI)
__________________________________________________________________*/
#include "script_component.hpp"
#include "\a3\editor_f\Data\Scripts\dikCodes.h"

if !(CHECK_INIT) exitWith {};

if (GVAR(enable) isEqualTo 0) exitWith {
	INFO("Addon is disabled.");
};

unassignCurator GVAR(curator);

PVEH_DEPLOY addPublicVariableEventHandler {[_this select 1] call FUNC(setup)};
PVEH_REQUEST addPublicVariableEventHandler {(_this select 1) call FUNC(handleRequest)};
PVEH_REASSIGN addPublicVariableEventHandler {(_this select 1) assignCurator GVAR(curator)};
PVEH_DELETE addPublicVariableEventHandler {
	{
		// ignore units in vehicles, only subtract cost of vehicle
		if (EGVAR(approval,enable) isEqualTo 1 && {!(_x isKindOf "Man") || (_x isKindOf "Man" && (isNull objectParent _x))}) then {
			_cost = [typeOf _x] call FUNC(getCuratorCost);
			_cost = _cost*COST_MULTIPIER;
			[getPosASL GVAR(anchor),_cost*-1] call EFUNC(approval,addValue);
		};
		_x call EFUNC(main,cleanup);
		false
	} count (curatorEditableObjects GVAR(curator));

	// remove objects from editable array so objects are not part of new FOB if placed in same position
	GVAR(curator) removeCuratorEditableObjects [curatorEditableObjects GVAR(curator),true];

	[getPosASL GVAR(anchor),AV_FOB*-1] call EFUNC(approval,addValue);
	unassignCurator GVAR(curator);
	[false] call FUNC(recon);
	deleteVehicle GVAR(anchor);

	GVAR(respawnPos) call BIS_fnc_removeRespawnPosition;

	{
		deleteLocation GVAR(location);
	} remoteExecCall [QUOTE(BIS_fnc_call), 0, false];
};

addMissionEventHandler ["HandleDisconnect",{
	if ((_this select 2) isEqualTo GVAR(UID)) then {unassignCurator GVAR(curator)};
	false
}];

[
	{DOUBLES(PREFIX,main)},
	{
		_data = QUOTE(ADDON) call EFUNC(main,loadDataAddon);

		[_data] call FUNC(handleLoadData);

		[[],{
			if (hasInterface) then {
				if (COMPARE_STR(GVAR(whitelist) select 0,"all") || {{COMPARE_STR(_x,player)} count GVAR(whitelist) > 0}) then {
	 				[QUOTE(ADDON),"Forward Operating Base","",QUOTE(true),QUOTE(call FUNC(getChildren))] call EFUNC(main,setAction);
				};

	 			[ADDON_TITLE, DEPLOY_ID, DEPLOY_NAME, {DEPLOY_KEYCODE}, ""] call CBA_fnc_addKeybind;
	 			[ADDON_TITLE, REQUEST_ID, REQUEST_NAME, {REQUEST_KEYCODE}, ""] call CBA_fnc_addKeybind;
	 			[ADDON_TITLE, DISMANTLE_ID, DISMANTLE_NAME, {DISMANTLE_KEYCODE}, ""] call CBA_fnc_addKeybind;
	 			[ADDON_TITLE, PATROL_ID, PATROL_NAME, {PATROL_KEYCODE}, ""] call CBA_fnc_addKeybind;
	 			[ADDON_TITLE, RECON_ID, RECON_NAME, {RECON_KEYCODE}, ""] call CBA_fnc_addKeybind;
	 			[ADDON_TITLE, BUILD_ID, BUILD_NAME, {BUILD_KEYCODE}, "", [DIK_DOWN, [true, false, false]]] call CBA_fnc_addKeybind;

	 			player addEventHandler ["Respawn",{
	 				if ((getPlayerUID (_this select 0)) isEqualTo GVAR(UID)) then {
	 					[
	 						{
	 							missionNamespace setVariable [PVEH_REASSIGN,player];
	 							publicVariableServer PVEH_REASSIGN;
	 						},
	 						[],
	 						5
	 					] call CBA_fnc_waitAndExecute;
	 				};
	 			}];
			};
 		}] remoteExecCall [QUOTE(BIS_fnc_call),0,true];
	}
] call CBA_fnc_waitUntilAndExecute;

ADDON = true;