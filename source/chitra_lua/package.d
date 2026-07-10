module chitra_lua;

import std.stdio;
import std.string;
import std.conv;

import chitra;
import lualibs;

alias LuaState = lua_State*;

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
