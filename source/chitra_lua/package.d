module chitra_lua;

import std.stdio;
import std.string;
import std.conv;

import chitra;
import lualibs;

alias LuaState = lua_State*;

Box parseSize(LuaState L)
{
    int argsCount = lua_gettop(L);
    double w = 0.0;
    double h = 0.0;

    double x = cast(double) lua_tonumber(L, 1);
    double y = cast(double) lua_tonumber(L, 2);
    if (argsCount >= 3 && lua_isnumber(L, 3))
        w = cast(double) lua_tonumber(L, 3);

    if (argsCount == 4 && lua_isnumber(L, 4))
        h = cast(double) lua_tonumber(L, 4);

    return Box(x, y, w, h);
}

int oval(LuaState L)
{
    auto box = parseSize(L);
    auto ctx = chitraContextFromGlobal(L);
    ctx.oval(box);

    return 0;
}

int rect(LuaState L)
{
    auto box = parseSize(L);
    auto ctx = chitraContextFromGlobal(L);
    ctx.rect(box);

    return 0;
}

int grid(LuaState L)
{
    int argsCount = lua_gettop(L);
    int rows = 1;
    int cols = 1;
    double gap = 0.0;

    if (argsCount >= 1 && lua_isinteger(L, 1))
        cols = cast(int) lua_tointeger(L, 1);

    if (argsCount > 1 && lua_isinteger(L, 2))
        rows = cast(int) lua_tointeger(L, 2);

    if ((argsCount == 2 && lua_istable(L, 2)) || (argsCount == 3 && lua_istable(L, 3)))
    {
        int idx = lua_istable(L, 2) ? 2 : 3;
        lua_getfield(L, idx, "gap");
        gap = cast(double) lua_tonumber(L, -1);
        lua_pop(L, 1);
    }

    auto ctx = chitraContextFromGlobal(L);
    ctx.grid(cols, rows, gap: gap);

    return 0;
}

void returnBox(LuaState L, Box box)
{
    // 1. Create a new empty table on the stack
    lua_newtable(L);

    lua_pushstring(L, "x");    // key
    lua_pushnumber(L, box.x);  // value
    lua_settable(L, -3);       // Pops key and value, sets them in table

    lua_pushstring(L, "y");
    lua_pushnumber(L, box.y);
    lua_settable(L, -3);

    lua_pushstring(L, "width"); 
    lua_pushnumber(L, box.width);
    lua_settable(L, -3); 

    lua_pushstring(L, "height");
    lua_pushnumber(L, box.height);
    lua_settable(L, -3);
}

int gridCell(LuaState L)
{
    int idx = cast(int) lua_tointeger(L, 1);

    auto ctx = chitraContextFromGlobal(L);
    auto box = ctx.gridCell(idx);
    returnBox(L, box);

    return 1;
}

int gridArea(LuaState L)
{
    int startNumber = cast(int) lua_tointeger(L, 1);
    int endNumber = cast(int) lua_tointeger(L, 2);

    auto ctx = chitraContextFromGlobal(L);
    auto box = ctx.gridArea(startNumber, endNumber);
    returnBox(L, box);

    return 1;
}

int size(LuaState L)
{
    int argsCount = lua_gettop(L);
    auto ctx = chitraContextFromGlobal(L);

    if (argsCount == 1 && lua_isinteger(L, 1))
    {
        auto w = cast(int)luaL_checkinteger(L, 1);
        ctx.setSize(w);
    }
    else if (argsCount == 2 && lua_isinteger(L, 1) && lua_isinteger(L, 2))
    {
        auto w = cast(int)luaL_checkinteger(L, 1);
        auto h = cast(int)luaL_checkinteger(L, 2);
        ctx.setSize(w, h);
    }
    else if (lua_isstring(L, 1))
    {
        auto paper = luaL_checkstring(L, 1).to!string;
        ctx.setSize(paper);
    }

    return 0;
}

int saveAs(LuaState L)
{
    int argsCount = lua_gettop(L);
    auto outfile = luaL_checkstring(L, 1).to!string;
    int resolution = 300;

    if (argsCount > 1)
    {
        luaL_checktype(L, 2, LUA_TTABLE);

        lua_getfield(L, 2, "resolution");
        resolution = cast(int) lua_tointeger(L, -1);
        lua_pop(L, 1);
    }
    auto ctx = chitraContextFromGlobal(L);
    ctx.saveAs(outfile, resolution: resolution);
    return 0;
}

Chitra chitraContextFromGlobal(LuaState L)
{
    lua_getglobal(L, "ctx");
    void* ctxRef = lua_touserdata(L, -1);
    return cast(Chitra)ctxRef;
}

void fromLuaString(string code, string output = "")
{
    // TODO: Error handling
    // TODO: Register all functions from Chitra
    Chitra ctx = new Chitra();
    lua_State* L = luaL_newstate();

    // Make the Chitra context in Lua integration function via
    // Lua Global variable ctx
    lua_pushlightuserdata(L, cast(void*)ctx);
    lua_setglobal(L, "ctx");

    luaL_openlibs(L);

    lua_register(L, "size", &size);
    lua_register(L, "save", &saveAs);
    lua_register(L, "grid", &grid);
    lua_register(L, "gridCell", &gridCell);
    lua_register(L, "gridArea", &gridArea);
    lua_register(L, "rect", &rect);
    lua_register(L, "oval", &oval);

    auto ret = luaL_dostring(L, code.toStringz);

    // TODO: Handle this error and cleanly terminate
    if (ret != LUA_OK) {
      writefln("Error: %s", lua_tostring(L, -1).fromStringz);
      lua_pop(L, 1); // pop error message
      return;
    }

    if (output != "")
        ctx.saveAs(output);

    ctx = null;
    lua_close(L);
}

unittest
{
    string code = q"[
    size(500, 200)
    save("size_500_200.png", {resolution=72})
    ]";
    fromLuaString(code);
}
