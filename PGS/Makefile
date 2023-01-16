# Invoking: appgen_module TMbase X 
# Invoking: appgen_module UDPtxin X 
# Makefile Generated Mon Jan 16 17:21:20 EST 2023
MNC=PGS
SPECFILE=PGS.spec
PCMFILE=PGS.pcm
SRC=/usr/local/share/monarch/modules/root.cmd
SRC+=/usr/local/share/monarch/modules/getcon.cmd
SRC+=/usr/local/share/monarch/modules/tdrift_col.tmc
SRC+=/usr/local/share/monarch/modules/cpu_usage_col.tmc
SRC+=/usr/local/share/monarch/modules/tmdf_col.tmc
SRC+=/usr/local/share/monarch/modules/freemem_col.tmc PGS.genui
SRC+=TMbase.genui PGS.pcm
TOOL=PGS.spec Makefile
SCRIPT=
OBJ=PGScmd.cc PGScmd.dat PGScmd.h PGScltnc.o PGScltncoui.cc
OBJ+=PGScltncoui.o PGSsrvr.o PGSsrvroui.cc PGSsrvroui.o PGScol.cc
OBJ+=tm.dac PGScoloui.cc PGScol.o PGScoloui.o PGSengext.cdf
OBJ+=PGSengextcdf.oui PGSengextcdf.tmc PGSengext.cc PGSengextoui.cc
OBJ+=PGSengext.o PGSengextoui.o
TGT=PGScltnc PGSsrvr PGScol PGSengext
IGNORE=
DISTRIB=../UDPtxin/TM/../UDPtxin ../Mouditxsrvr ../Moudicltnc
DISTRIB+=PGS.pcm tm.dac
IDISTRIB=Experiment.config VERSION
SRCDIST=PGS.tmc /usr/local/share/monarch/modules/tdrift.tmc
SRCDIST+=/usr/local/share/monarch/modules/cpu_usage.tmc
SRCDIST+=/usr/local/share/monarch/modules/tmdf.tmc freemem.tmc
SRCDIST+=/usr/local/share/monarch/modules/flttime.tmc
TMCBASE=PGS.tmc /usr/local/share/monarch/modules/tdrift.tmc
TMCBASE+=/usr/local/share/monarch/modules/cpu_usage.tmc
TMCBASE+=/usr/local/share/monarch/modules/tmdf.tmc freemem.tmc
TMCBASE+=/usr/local/share/monarch/modules/flttime.tmc
CMDBASE=/usr/local/share/monarch/modules/root.cmd
CMDBASE+=/usr/local/share/monarch/modules/getcon.cmd
COLBASE=/usr/local/share/monarch/modules/tdrift_col.tmc
COLBASE+=/usr/local/share/monarch/modules/cpu_usage_col.tmc
COLBASE+=/usr/local/share/monarch/modules/tmdf_col.tmc
COLBASE+=/usr/local/share/monarch/modules/freemem_col.tmc
SWSBASE=
QCLIBASE=
GENUIBASE=PGS.genui TMbase.genui
EXTBASE=
SPECDEPBASE=/usr/local/share/monarch/modules/TMbase.agm
SPECDEPBASE+=/usr/local/share/monarch/modules/freemem_def.tmc.in
SPECDEPBASE+=/usr/local/share/monarch/modules/TMbase.genui.in
SPECDEPBASE+=/usr/local/share/monarch/modules/TMbase.tbl.in
SPECDEPBASE+=../UDPtxin/TM/UDPtxin.agm
SPECTGTBASE=freemem.tmc TMbase.genui TMbase.tbl
SPECTGTMISS:=$(foreach file,$(SPECTGTBASE),$(if $(wildcard $(file)),,$(file)))
AG_CPPFLAGS=-std=c++11
PHTGT=
SOURCE=$(SRC) $(TOOL) $(SCRIPT)
OBJECT=$(OBJ) *.err
TARGET=$(TGT)
DSTRB=$(TGT) $(DISTRIB) $(SCRIPT)
TGTDIR= /home/moudi/PGS
include /usr/local/share/monarch/appgen.mk

.PHONY : all all-dist extdistribution distribution tidy clean clean-dist check_photon

IGNOREFILE=.gitignore
all : check_photon $(TGT) $(IGNOREFILE)
all-dist : all $(DSTRB) $(SRCDIST) VERSION
Makefile $(SPECTGTMISS) : PGS.spec $(SPECDEPBASE)
	appgen PGS.spec
VERSION=`cat VERSION`
extdistribution : all-dist
	@distribute_check $(TGTDIR)/bin/$(VERSION) $(PCMFILE)
	@distribute $(FORCE) $(TGTDIR)/bin/$(VERSION) $(DSTRB)
	@distribute $(FORCE) $(TGTDIR)/bin/$(VERSION)/Base $(SRCDIST)
distribution : extdistribution
	@distribute $(FORCE) $(TGTDIR) $(IDISTRIB)
check_photon :
ifeq ($(WPHOTON),YES)
${tab}@for tgt in $(PHTGT); do \\
${tab}  cmp -s $$tgt /usr/local/share/monarch/nulltbl.tmc && echo Remaking $$tgt && rm -f $$tgt; \\
${tab}done; true
endif
PGScltnc : PGScltnc.o PGScltncoui.o
	$(LINK.normCXX) PGScltnc.o PGScltncoui.o -ldasio -lpthread -lncurses -lnl
	$(OUIUSE) PGScltncoui.cc
PGSsrvr : PGSsrvr.o PGSsrvroui.o
	$(LINK.privCXX) PGSsrvr.o PGSsrvroui.o -ldasio -lpthread -lnl
	$(OUIUSE) PGSsrvroui.cc
	$(PROMOTE) PGSsrvr
PGScol : PGScol.o PGScoloui.o
	$(LINK.privCXX) PGScol.o PGScoloui.o -ldasio -lpthread -lnl
	$(OUIUSE) PGScoloui.cc
	$(PROMOTE) PGScol
PGSengext : PGSengext.o PGSengextoui.o
	$(LINK.normCXX) PGSengext.o PGSengextoui.o -ldasio -lpthread -lnl
	$(OUIUSE) PGSengextoui.cc
PGScmd.cc : /usr/local/share/monarch/modules/root.cmd /usr/local/share/monarch/modules/getcon.cmd
	cmdgen_version PGScmd /usr/local/share/monarch/modules/root.cmd /usr/local/share/monarch/modules/getcon.cmd
PGScltnc.o : PGScmd.cc
	$(COMPILE.cltnc) PGScmd.cc
PGScltncoui.cc : $(OUIDIR)/kbdclt.oui $(OUIDIR)/nctable.oui $(OUIDIR)/msg.oui
	$(OUI) $(OUIDIR)/kbdclt.oui $(OUIDIR)/nctable.oui $(OUIDIR)/msg.oui
PGScltncoui.o : PGScltncoui.cc
PGSsrvr.o : PGScmd.cc
	$(COMPILE.srvr) PGScmd.cc
PGSsrvroui.cc : $(OUIDIR)/cmd_server.oui $(OUIDIR)/seteuid.oui $(OUIDIR)/msg.oui
	$(OUI) $(OUIDIR)/cmd_server.oui $(OUIDIR)/seteuid.oui $(OUIDIR)/msg.oui
PGSsrvroui.o : PGSsrvroui.cc
PGScol.cc : PGS.tmc /usr/local/share/monarch/modules/tdrift.tmc /usr/local/share/monarch/modules/cpu_usage.tmc /usr/local/share/monarch/modules/tmdf.tmc freemem.tmc /usr/local/share/monarch/modules/flttime.tmc /usr/local/share/monarch/modules/tdrift_col.tmc /usr/local/share/monarch/modules/cpu_usage_col.tmc /usr/local/share/monarch/modules/tmdf_col.tmc /usr/local/share/monarch/modules/freemem_col.tmc VERSION
	$(TMC.col) PGS.tmc /usr/local/share/monarch/modules/tdrift.tmc /usr/local/share/monarch/modules/cpu_usage.tmc /usr/local/share/monarch/modules/tmdf.tmc freemem.tmc /usr/local/share/monarch/modules/flttime.tmc /usr/local/share/monarch/modules/tdrift_col.tmc /usr/local/share/monarch/modules/cpu_usage_col.tmc /usr/local/share/monarch/modules/tmdf_col.tmc /usr/local/share/monarch/modules/freemem_col.tmc
PGScoloui.cc : $(OUIDIR)/collect.oui $(OUIDIR)/seteuid.oui $(OUIDIR)/msg.oui
	$(OUI) $(OUIDIR)/collect.oui $(OUIDIR)/seteuid.oui $(OUIDIR)/msg.oui
PGScol.o : PGScol.cc
PGScoloui.o : PGScoloui.cc
PGSengext.cdf : PGS.genui TMbase.genui
	$(GENUI2ENG) PGS.genui TMbase.genui
PGSengextcdf.oui : PGSengext.cdf
	$(EDF2OUI) PGSengext.cdf
PGSengextcdf.tmc : PGSengext.cdf
	$(EDF2EXT) PGSengext.cdf
PGSengext.cc : PGS.tmc /usr/local/share/monarch/modules/tdrift.tmc /usr/local/share/monarch/modules/cpu_usage.tmc /usr/local/share/monarch/modules/tmdf.tmc freemem.tmc /usr/local/share/monarch/modules/flttime.tmc PGSengextcdf.tmc VERSION
	$(TMC) PGS.tmc /usr/local/share/monarch/modules/tdrift.tmc /usr/local/share/monarch/modules/cpu_usage.tmc /usr/local/share/monarch/modules/tmdf.tmc freemem.tmc /usr/local/share/monarch/modules/flttime.tmc PGSengextcdf.tmc
PGSengextoui.cc : PGSengextcdf.oui $(OUIDIR)/tm_client.oui $(OUIDIR)/msg.oui
	$(OUI) PGSengextcdf.oui $(OUIDIR)/tm_client.oui $(OUIDIR)/msg.oui
PGSengext.o : PGSengext.cc
PGSengextoui.o : PGSengextoui.cc

tidy :
	rm -f $(OBJECT)
clean : tidy
	rm -f $(TARGET)
clean-dist : clean
$(IGNOREFILE) : Makefile
	@for i in $(OBJECT) $(IGNORE) $(TARGET); do echo "$$i"; done >$(IGNOREFILE)
.PHONY : clean-UDPtxin ../UDPtxin/TM/../UDPtxin
../UDPtxin/TM/../UDPtxin :
	$(MAKE) --directory=../UDPtxin/TM/..
clean-dist : clean-UDPtxin
clean-UDPtxin :
	$(MAKE) --directory=../UDPtxin/TM/.. clean
# This matches the current definitions in monarch dasio
# and is necessary to see addrinfo/getaddrinfo needed for
# UDP.
CXXFLAGS=-Wall -g -D_POSIX_C_SOURCE=200809L
