/*
Author:
Nicholas Clark (SENSEI)
__________________________________________________________________*/
#include "script_component.hpp"

if !(isServer) exitWith {};

ADDON = false;

PREP(deploy);
PREP(delete);
PREP(request);
PREP(requestAnswer);
PREP(requestReceive);
PREP(requestHandler);
PREP(setup);
PREP(getChildren);
PREP(canDeploy);

GVAR(location) = locationNull;
GVAR(UID) = "";
GVAR(response) = -1;
GVAR(flag) = objNull;

publicVariable QFUNC(request);
publicVariable QFUNC(requestReceive);
publicVariable QFUNC(requestAnswer);
publicVariable QFUNC(getChildren);
publicVariable QFUNC(deploy);
publicVariable QFUNC(canDeploy);
publicVariable QGVAR(location);
publicVariable QGVAR(UID);
publicVariable QGVAR(response);