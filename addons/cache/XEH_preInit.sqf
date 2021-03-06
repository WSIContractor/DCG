/*
Author:
Nicholas Clark (SENSEI)
__________________________________________________________________*/
#include "script_component.hpp"

CHECK_PREINIT;

ADDON = false;

PREP(initSettings);
PREP(handleCache);
PREP(disableCache);

publicVariable QFUNC(initSettings);

SETTINGS_INIT;
