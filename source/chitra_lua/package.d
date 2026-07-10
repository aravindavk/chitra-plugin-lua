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

int colorScale(LuaState L)
{
    int argsCount = lua_gettop(L);
    int maxA = 0;
    auto maxRGB = cast(int)luaL_checkinteger(L, 1);

    if (argsCount == 2 && lua_isinteger(L, 2))
        maxA = cast(int)luaL_checkinteger(L, 2);

    auto ctx = chitraContextFromGlobal(L);
    ctx.colorScale(maxRGB, maxA);

    return 0;
}

int colorHandler(string name)(LuaState L)
{
    int argsCount = lua_gettop(L);
    auto ctx = chitraContextFromGlobal(L);
    auto opacity = -1.0;

    if (argsCount >= 3)
    {
        auto r = cast(double)luaL_checknumber(L, 1);
        auto g = cast(double)luaL_checknumber(L, 2);
        auto b = cast(double)luaL_checknumber(L, 3);

        if (argsCount == 4 && lua_isnumber(L, 4))
            opacity = cast(double)luaL_checknumber(L, 4);

        mixin(`ctx.` ~ name ~ `(r, g, b, opacity);`);
    }
    else if (argsCount >= 1 && lua_isnumber(L, 1))
    {
        auto gray = cast(double)luaL_checknumber(L, 1);

        if (argsCount == 2 && lua_isnumber(L, 2))
            opacity = cast(double)luaL_checknumber(L, 2);

        mixin(`ctx.` ~ name ~ `(gray, opacity);`);
    }
    else if (argsCount >= 1 && lua_isstring(L, 1))
    {
        auto col = luaL_checkstring(L, 1).to!string;
        if (argsCount == 2 && lua_isnumber(L, 2))
            opacity = cast(double)luaL_checknumber(L, 2);

        mixin(`ctx.` ~ name ~ `(col, opacity);`);
    }

    return 0;
}

int fill(LuaState L)
{
    return colorHandler!"fill"(L);
}

int stroke(LuaState L)
{
    return colorHandler!"stroke"(L);
}

int tint(LuaState L)
{
    return colorHandler!"tint"(L);
}

int noTint(LuaState L)
{
    auto ctx = chitraContextFromGlobal(L);
    ctx.noTint;

    return 0;
}

int background(LuaState L)
{
    return colorHandler!"background"(L);
}

int noFill(LuaState L)
{
    auto ctx = chitraContextFromGlobal(L);
    ctx.noFill;

    return 0;
}

int noStroke(LuaState L)
{
    auto ctx = chitraContextFromGlobal(L);
    ctx.noStroke;

    return 0;
}

int newDrawing(LuaState L)
{
    auto ctx = chitraContextFromGlobal(L);
    ctx.newDrawing;

    return 0;
}

int newPage(LuaState L)
{
    auto ctx = chitraContextFromGlobal(L);
    ctx.newPage;

    return 0;
}

int strokeWidth(LuaState L)
{
    auto w = cast(int)luaL_checkinteger(L, 1);
    auto ctx = chitraContextFromGlobal(L);
    ctx.strokeWidth(w);

    return 0;
}

int ovalMode(LuaState L)
{
    auto mode = luaL_checkstring(L, 1).to!string;
    auto ctx = chitraContextFromGlobal(L);
    ctx.ovalMode(mode);

    return 0;
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

int textFont(LuaState L)
{
    int argsCount = lua_gettop(L);
    string fontName = lua_tostring(L, 1).to!string;
    double fontSize = 16.0;

    if (argsCount == 2 && lua_isnumber(L, 2))
        fontSize = cast(double) lua_tonumber(L, 2);

    auto ctx = chitraContextFromGlobal(L);
    ctx.textFont(fontName, fontSize);

    return 0;
}

int overflowText(LuaState L)
{
    auto ctx = chitraContextFromGlobal(L);
    lua_pushstring(L, ctx.overflowText.toStringz);

    return 1;
}

int line(LuaState L)
{
    auto x1 = cast(double) lua_tonumber(L, 1);
    auto y1 = cast(double) lua_tonumber(L, 2);
    auto x2 = cast(double) lua_tonumber(L, 3);
    auto y2 = cast(double) lua_tonumber(L, 4);

    auto ctx = chitraContextFromGlobal(L);
    ctx.line(x1, y1, x2, y2);

    return 0;
}

int textSize(LuaState L)
{
    int argsCount = lua_gettop(L);
    string txt = lua_tostring(L, 1).to!string;
    double w = 0.0;
    double h = 0.0;

    if (argsCount >= 2 && lua_isnumber(L, 2))
        w = cast(double) lua_tonumber(L, 2);

    if (argsCount == 3 && lua_isnumber(L, 3))
        h = cast(double) lua_tonumber(L, 3);

    auto ctx = chitraContextFromGlobal(L);
    returnBox(L, ctx.textSize(txt, w, h));

    return 1;
}

int text(LuaState L)
{
    int argsCount = lua_gettop(L);
    double w = 0.0;
    double h = 0.0;

    string txt = lua_tostring(L, 1).to!string;
    double x = cast(double) lua_tonumber(L, 2);
    double y = cast(double) lua_tonumber(L, 3);
    if (argsCount >= 3 && lua_isnumber(L, 4))
        w = cast(double) lua_tonumber(L, 4);

    if (argsCount == 4 && lua_isnumber(L, 5))
        h = cast(double) lua_tonumber(L, 5);

    auto ctx = chitraContextFromGlobal(L);
    ctx.text(txt, x, y, w, h);

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

    // Export CENTER, RADIUS, CORNER and CORNERS as global vars
    lua_pushstring(L, "CENTER");
    lua_setglobal(L, "CENTER");

    lua_pushstring(L, "RADIUS");
    lua_setglobal(L, "RADIUS");

    lua_pushstring(L, "CORNER");
    lua_setglobal(L, "CORNER");

    lua_pushstring(L, "CORNERS");
    lua_setglobal(L, "CORNERS");

    luaL_openlibs(L);

    lua_register(L, "size", &size);
    lua_register(L, "save", &saveAs);
    lua_register(L, "grid", &grid);
    lua_register(L, "grid_cell", &gridCell);
    lua_register(L, "grid_area", &gridArea);
    lua_register(L, "rect", &rect);
    lua_register(L, "square", &rect);
    lua_register(L, "oval_mode", &ovalMode);
    lua_register(L, "oval", &oval);
    lua_register(L, "circle", &oval);
    lua_register(L, "color_scale", &colorScale);
    lua_register(L, "fill", &fill);
    lua_register(L, "stroke", &stroke);
    lua_register(L, "background", &background);
    lua_register(L, "no_fill", &noFill);
    lua_register(L, "no_stroke", &noStroke);
    lua_register(L, "stroke_width", &strokeWidth);
    lua_register(L, "tint", &tint);
    lua_register(L, "no_tint", &noTint);
    lua_register(L, "text_font", &textFont);
    lua_register(L, "overflow_text", &overflowText);
    lua_register(L, "text_size", &textSize);
    lua_register(L, "text", &text);
    lua_register(L, "new_drawing", &newDrawing);
    lua_register(L, "new_page", &newPage);
    lua_register(L, "line", &line);

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
