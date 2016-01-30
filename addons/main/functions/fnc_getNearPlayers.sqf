/*
Author:
Nicholas Clark (SENSEI)

Description:
gets near players

Arguments:

Return:
array
__________________________________________________________________*/
#include "script_component.hpp"

private ["_pos","_range","_players"];

_pos = _this select 0;
_range = _this select 1;
_players = [];

{
	if (isPlayer _x) then {_players pushBack _x};
} forEach (_pos nearEntities ["Man", _range]);

_players