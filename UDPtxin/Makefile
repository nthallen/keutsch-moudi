LDFLAGS=-L /usr/local/lib
CPPFLAGS= -I /usr/local/include -I ../TM
CXXFLAGS= -Wall -g
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
