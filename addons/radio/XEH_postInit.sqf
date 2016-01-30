/*
Author:
Nicholas Clark (SENSEI)
__________________________________________________________________*/
#include "script_component.hpp"

if !(isServer) exitWith {};

if (GVAR(enable) isEqualTo 0) exitWith {
	LOG_DEBUG("Addon is disabled.");
};

publicVariable QFUNC(setRadio);
publicVariable QFUNC(setRadioTFAR);
publicVariable QFUNC(setRadioACRE);

remoteExecCall [QFUNC(checkLoadout), 0, true];
remoteExec [QFUNC(setRadioSettings), 0, true];

ADDON = true;