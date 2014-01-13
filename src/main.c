#include <stdlib.h>
#include <stdio.h>
#include <getopt.h>
#include <luajit-2.0/lua.h>
#include <luajit-2.0/lualib.h>
#include <luajit-2.0/lauxlib.h>

#define CHECK_LOADED(i) if(i) {\
                          fprintf(stderr, "Problem loading the interpreter: %s\n",\
                                  lua_tostring(L, -1));\
                          exit(i);\
                        }

extern int luaopen_lpeg(lua_State *);

void
ay_pusheval(lua_State *L, const char *optarg) {
  lua_getfield(L, -1, "evallist");
  if (lua_isnil(L, -1)) {
    lua_pop(L, 1);
    lua_newtable(L);
  }
  size_t idx = lua_objlen(L, -1) + 1;
  lua_pushstring(L, optarg);
  lua_rawseti(L, -2, idx);
  lua_setfield(L, -2, "evallist");
  return;
}

int
main(int argc, char *argv[]) {
  int status, result, opt, debug;
  struct option cliopts[] = {
    {"debug", no_argument, NULL, 'd'},
    {"verbose", no_argument, NULL, 'v'},
    {0, 0, 0, 0}
  };

  lua_State *L;

  L = luaL_newstate();
  luaL_openlibs(L);
  luaopen_lpeg(L);

  // Prepare to call main with a table generated from CLI arguments
  luaL_dostring(L, "require \"main\"");
  lua_getglobal(L, "main");
  lua_newtable(L);

  // Parse CLI arguments, pushing appropriate values into the table to be passed
  while((opt = getopt_long(argc, argv, "e:d", cliopts, NULL)) != -1) {
    switch (opt) {
      case 'e':
        ay_pusheval(L, optarg);
        break;
      case 'd':
        debug = 1;
        break;
      case 0:
        break;
    }
  }

  lua_pushboolean(L, debug);
  lua_setfield(L, -2, "debug");

  // Last remaining argument should be source file to run
  if (optind < argc) {
    lua_pushstring(L, argv[optind]);
    lua_setfield(L, -2, "srcfile");
  }

  CHECK_LOADED(lua_pcall(L, 1, 0, 0));

  return 0;
}
