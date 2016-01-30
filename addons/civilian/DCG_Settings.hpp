/*
    Types (SCALAR, BOOL, STRING, ARRAY)
*/

class DOUBLES(PREFIX,settings) {
    class GVAR(enable) {
        typeName = "SCALAR";
        typeDetail = "";
        value = 1;
    };
    class GVAR(spawnDist) {
        typeName = "SCALAR";
        typeDetail = "";
        value = 500;
    };
    class GVAR(count) {
        typeName = "SCALAR";
        typeDetail = "";
        value = 15;
    };
    class GVAR(vehCount) {
        typeName = "SCALAR";
        typeDetail = "";
        value = 2;
    };
    class GVAR(cityMultiplier) {
        typeName = "SCALAR";
        typeDetail = "";
        value = 0.5;
    };
    class GVAR(townMultiplier) {
        typeName = "SCALAR";
        typeDetail = "";
        value = 0.25;
    };
    class GVAR(hostileChance) {
        typeName = "SCALAR";
        typeDetail = "";
        value = 0.05;
    };
};