
TESTDIR=$(dirname $0)
LJ=$PWD/src/luajit

#  LuaJIT-test-cleanup

cd $TESTDIR/LuaJIT-test-cleanup/test && $LJ test.lua $LJ_TEST_ARGS
