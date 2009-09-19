#include <iostream>
#include <lua5.1/lua.hpp>
extern "C" {
	#include <lua5.1/luasocket.h>
}

extern "C" int luaopen_socket_core(lua_State *L);
extern "C" int luaopen_mime_core(lua_State *L);

using namespace std;

int main(int argc, const char **argv)
{
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
	lua_newtable(L);
	for (int i = 0; i <= argc; i++)
	{
		lua_pushnumber(L, i);
		lua_pushstring(L, argv[i]);
		lua_settable(L, -3);
	}
	lua_setglobal(L, "arg");
	lua_getglobal(L, "package");
	lua_getfield(L, -1, "preload");
	lua_pushstring(L, "socket.core");
	lua_pushcfunction(L, luaopen_socket_core);
	lua_settable(L, -3);
	lua_pushstring(L, "mime.core");
	lua_pushcfunction(L, luaopen_mime_core);
	lua_settable(L, -3);
	if (luaL_loadfile(L, "main.lua") != 0)
	{
		cout<<"An error occured while loading Juiz" <<endl;
		return 1;
	}
	if (lua_pcall(L, 0, 0, 0) != 0)
	{
		cout<<lua_tostring(L, -1) <<endl;
		return 1;
	}
	return 0;
}
