/*
Author:
Nicholas Clark (SENSEI)

Description:
set units on patrol

Arguments:
0: array of units <ARRAY>
1: max distance from original position a unit will patrol or max distance from previous position if group patrol <NUMBER>
2: patrol as group or individual <BOOL>

Return:
boolean
__________________________________________________________________*/
#include "script_component.hpp"
#define MINRANGE _range*0.4
#define WAYPOINT_UNITREADY !(behaviour _unit isEqualTo "COMBAT")
#define WAYPOINT_POS (_waypoint select 0)
#define WAYPOINT_TIME (_waypoint select 1)
#define WAYPOINT_TIMEMAX (_waypoint select 2)
#define WAYPOINT_RESETPOS _waypoint set [0,[]]
#define WAYPOINT_RESETTIME _waypoint set [1,0]; _waypoint set [2,0]
#define WAYPOINT_EMPTY [[],0,0]
#define WAYPOINT_ADD(DIST) _waypoint set [0,_pos]; _waypoint set [1,diag_tickTime]; _waypoint set [2,((getpos _unit distance2D _pos)/DIST)*60]
#define WAYPOINT_BUFFER 5
#define PATROL_VAR QUOTE(DOUBLES(PREFIX,isOnPatrol))

private ["_pos","_grp","_posStart","_type","_d","_r","_roads","_veh","_road","_houses","_housePosArray"];
params ["_units",["_range",100],["_individual",true]];

if (_units isEqualTo []) exitWith {false};

{
    if !(_individual) exitWith { // group patrol
        // check if units are in same group
        _grp = group _x;
        {
            if !(group _x isEqualTo _grp) exitWith { // if a unit is not in the same group, regroup all units
                _grp = [_units,side _grp] call FUNC(setSide);
            };
        } forEach _units;

        _grp setBehaviour "SAFE";
        _posStart = getPosATL (leader _grp);

        private ["_posPrev"];
        _posPrev = _posStart;
        for "_i" from 0 to (2 + (floor (random 3))) do {
            private ["_pos","_waypoint"];
            _pos = [_posPrev,_range*0.5,_range] call FUNC(findRandomPos);
            _posPrev = _pos;
            _waypoint = _grp addWaypoint [_pos,0];
            _waypoint setWaypointType "MOVE";
            _waypoint setWaypointCompletionRadius 20;

            if (_i isEqualTo 0) then {
                _waypoint setWaypointSpeed "LIMITED";
                _waypoint setWaypointFormation "STAG COLUMN";
            };
        };

        private "_waypoint";
        _waypoint = _grp addWaypoint [_posStart, 0];
        _waypoint setWaypointType "CYCLE";
        _waypoint setWaypointCompletionRadius 20;

        (leader _grp) setVariable [PATROL_VAR,1];

        true
    };

    _waypoint = WAYPOINT_EMPTY;
    _x setBehaviour "SAFE";

    if (!((vehicle _x) isEqualTo _x) && {_x isEqualTo (driver (vehicle _x))}) then { // if unit is in a vehicle and is the driver
        private ["_veh","_roads"];
        _veh = vehicle _x;
        _veh addEventHandler ["Fuel",{if !(_this select 1) then {(_this select 0) setFuel 1}}];
        _roads = [];

        if !(_veh isKindOf "AIR") then {
            _roads = (getPosATL _x) nearRoads (_range min 1000);
            _veh forceSpeed (_veh getSpeed "SLOW");
        } else {
            _veh forceSpeed (_veh getSpeed "NORMAL");
            _veh flyInHeight 150;
        };

        [{
            params ["_args","_idPFH"];
            _args params ["_unit","_posStart","_range","_waypoint","_roads","_type"];

            _veh = vehicle _unit;

            if (!alive _veh || {!alive _unit} || {_unit getVariable [PATROL_VAR,-1] isEqualTo 0}) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
                _veh forceSpeed (_veh getSpeed "AUTO");
                LOG_DEBUG_2("%1 exiting patrol at %2.",_type,getPosASL _veh);
            };

            if (WAYPOINT_UNITREADY) then {
                if !(WAYPOINT_POS isEqualTo []) then { // unit has a waypoint
                    if (CHECK_DIST2D(WAYPOINT_POS,_unit,WAYPOINT_BUFFER)) then { // unit is close enough to waypoint, delete waypoint
                        WAYPOINT_RESETPOS;
                        WAYPOINT_RESETTIME;
                    };
                };
                if (_waypoint isEqualTo WAYPOINT_EMPTY || {diag_tickTime >= (WAYPOINT_TIME + WAYPOINT_TIMEMAX)}) then { // if unit near waypoint or unit did not reach waypoint in time, find new waypoint
                    if (_roads isEqualTo []) then {
                        _d = random 360;
                        _r = floor (random ((_range - MINRANGE) + 1)) + MINRANGE;
                        _pos = [(_posStart select 0) + (sin _d) * _r, (_posStart select 1) + (cos _d) * _r, (getPosATL _unit) select 2];
                        if !(_veh isKindOf "AIR") then {
                            if !(surfaceIsWater _pos) then {
                                _unit doMove _pos;
                                WAYPOINT_ADD(150); // set waypoint array, argument determines how long unit has to reach waypoint
                            };
                        } else {
                            _unit doMove _pos;
                            WAYPOINT_ADD(150);
                        };
                    } else {
                        _pos = getPosATL (_roads select floor (random (count _roads)));
                        _unit doMove _pos;
                        WAYPOINT_ADD(150);
                    };
                };
            };
        }, 30, [_x,getPosATL _x,_range,_waypoint,_roads,typeOf (vehicle _x)]] call CBA_fnc_addPerFrameHandler;

        _x setVariable [PATROL_VAR,1];
    };

    if ((vehicle _x) isEqualTo _x) then { // if unit is on foot
        private ["_houses"];
        _x forceSpeed (_x getSpeed "SLOW");
        _houses = (getposATL _x) nearObjects ["house",_range min 1000];

        [{
            params ["_args","_idPFH"];
            _args params ["_unit","_posStart","_range","_waypoint","_houses","_type"];

            if (!alive _unit || {_unit getVariable [PATROL_VAR,-1] isEqualTo 0}) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
                _unit forceSpeed (_unit getSpeed "AUTO");
                LOG_DEBUG_2("%1 exiting patrol at %2.", _type, getPosASL _unit);
            };

            if (WAYPOINT_UNITREADY) then {
                if !(WAYPOINT_POS isEqualTo []) then { // unit has a waypoint
                    if (CHECK_DIST2D(WAYPOINT_POS,_unit,WAYPOINT_BUFFER)) then { // unit is close enough to waypoint, delete waypoint
                        WAYPOINT_RESETPOS;
                        WAYPOINT_RESETTIME;
                    };
                };
                if (_waypoint isEqualTo WAYPOINT_EMPTY || {diag_tickTime >= (WAYPOINT_TIME + WAYPOINT_TIMEMAX)}) then { // if unit near waypoint or unit did not reach waypoint in time, find new waypoint
                    // TODO add code to reset units when they get stuck
                    if (!(_houses isEqualTo []) && {random 1 < 0.5}) then {
                        private ["_housePosArray"];
                        _housePosArray = [_houses select floor(random (count _houses)), 3] call BIS_fnc_buildingPositions;
                        if !(_housePosArray isEqualTo []) then {
                            _pos = _housePosArray select floor(random (count _housePosArray));
                            _unit doMove _pos;
                            WAYPOINT_ADD(100); // set waypoint array, argumment determines how long unit has to reach waypoint
                        };
                    } else {
                        _d = random 360;
                        _r = floor (random ((_range - MINRANGE) + 1)) + MINRANGE;
                        _pos = [(_posStart select 0) + (sin _d) * _r, (_posStart select 1) + (cos _d) * _r, 0];
                        if !(surfaceIsWater _pos) then {
                            _unit doMove _pos;
                            WAYPOINT_ADD(100);
                        };
                    };
                };
            };
        }, 30, [_x,getPosATL _x,_range,_waypoint,_houses,typeOf (vehicle _x)]] call CBA_fnc_addPerFrameHandler;

        _x setVariable [PATROL_VAR,1];
    };
} forEach _units;

true