#define COMPONENT patrol
#include "\d\dcg\addons\main\script_mod.hpp"
#include "\d\dcg\addons\main\script_macros.hpp"

#define UNITCOUNT(MIN,MAX) floor (random ((MAX - MIN) + 1)) + MIN
#define PATROL_MINRANGE 300
#define PATROL_RANGE 1000