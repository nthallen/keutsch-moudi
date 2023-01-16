tmcbase = base.tmc
tmcbase = uDACS.tmc
tmcbase = uDACS_A.tmc

extbase = uDACS_A_conv.tmc

colbase = uDACS_col.tmc
colbase = uDACS_A_col.tmc

genuibase = Moudi.genui
genuibase = uDACS.genui

cmdbase = Moudi.cmd
cmdbase = uDACS.cmd

swsbase = Moudi.sws

Module TMbase
Module alicat src=alicat.txt TX=^
Module IWG1

TGTDIR = /home/moudi
IGNORE = "*.o" "*.exe" "*.stackdump" Makefile
DISTRIB = services interact runfile.flight
DISTRIB = USB_ID.exp Rovers.txt
IDISTRIB = doit

Moudicol : -lsubbuspp
Moudisrvr : -lsubbuspp uDACS_cmd.oui
Mouditxsrvr :
Moudidisp : uDACS_A_conv.tmc Moudi.tbl
IWG1disp : IWG1.tbl
Moudialgo : uDACS_A_conv.tmc Moudi.tma $swsbase
UDPrxext : uDACS_A_conv.tmc UDP.tmc UDP.cc UDPrx.cc UDPext.oui
doit : Moudi.doit
GSEdoit : GSE.doit
%%
# This matches the current definitions in monarch dasio
# and is necessary to see addrinfo/getaddrinfo needed for
# UDP.
CXXFLAGS=-Wall -g -D_POSIX_C_SOURCE=200809L
