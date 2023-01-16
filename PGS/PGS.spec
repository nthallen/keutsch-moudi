tmcbase = PGS.tmc
genuibase = PGS.genui

Module TMbase
Module UDPtxin

TGTDIR = /home/moudi/PGS
DISTRIB = ../Mouditxsrvr ../Moudicltnc

%%
# This matches the current definitions in monarch dasio
# and is necessary to see addrinfo/getaddrinfo needed for
# UDP.
CXXFLAGS=-Wall -g -D_POSIX_C_SOURCE=200809L
