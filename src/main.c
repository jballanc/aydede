#include <stdlib.h>
#include <stdio.h>
#include <luajit-2.0/lua.h>
#include <luajit-2.0/lualib.h>
#include <luajit-2.0/lauxlib.h>

#define CHECK_LOADED(i) if(i) {\
                          fprintf(stderr, "Problem loading the interpreter: %s\n",\
                                  lua_tostring(L, -1));\
                          exit(i);\
                        }

extern int luaopen_lpeg(lua_State *);

int
main(int argc, char *argv[]) {
  int status, result;
  lua_State *L;

  L = luaL_newstate();
  luaL_openlibs(L);
  luaopen_lpeg(L);

  luaL_dostring(L, "require \"main\"");
  lua_getglobal(L, "main");
  CHECK_LOADED(lua_pcall(L, 0, 0, 0));

  return 0;
}
