LDFLAGS=-L /usr/local/lib
CPPFLAGS= -I /usr/local/include -I ../TM
# Define LAB_TEST_CAMBRIDGE to test on the 10.245.83.0/25 subnet
# Define LAB_TEST_FIELD to test on the 10.11.96.0/24 subnet
#   (aircraft w/o the aircraft sat connections
# Define neither for flight mode operation
# The same change also needs to be made in src/TM/Moudi.spec
CXXFLAGS= -Wall -g -DLAB_TEST_CAMBRIDGE -D_DEFAULT_SOURCE -D_POSIX_SOURCE=1 -D_XOPEN_SOURCE=500 -D_POSIX_C_SOURCE=20080 -std=c++11
LIBS=-ldasio -lnl -lpthread

UDPtxinSRC = UDPtxin.cc UDPtxinoui.cc ../TM/UDP.cc
UDPtxinOBJ = ${addsuffix .o, ${basename $(UDPtxinSRC) } } 
UDPtxinTGT = UDPtxin

.PHONY : all clean

all : UDPtxin

$(UDPtxinTGT) : $(UDPtxinOBJ)
	$(LINK.cc) -o $(UDPtxinTGT) $(UDPtxinOBJ) $(LIBS)
UDPtxinoui.cc : UDPtxin.oui
	oui -o UDPtxinoui.cc UDPtxin.oui

clean :
	rm -f *.o UDPtxinoui.cc UDPtxin
