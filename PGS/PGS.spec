tmcbase = PGS.tmc
genuibase = PGS.genui

Module TMbase
Module UDPtxin

TGTDIR = /home/moudi/PGS
IGNORE = "*.o" "*.exe" "*.stackdump" Makefile
DISTRIB = services interact
DISTRIB = ../TM/Mouditxsrvr ../TM/Moudicltnc ../TM/PGSalgo

PGSdisp : PGS.tbl
PGSjsonext : $extbase $genuibase
doit : PGS.doit

%%
# This matches the current definitions in monarch dasio
# and is necessary to see addrinfo/getaddrinfo needed for
# UDP.
CXXFLAGS=-Wall -g -D_POSIX_C_SOURCE=200809L
