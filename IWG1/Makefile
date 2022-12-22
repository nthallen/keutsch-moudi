LDFLAGS=-L /usr/local/lib
CPPFLAGS= -I /usr/local/include
CXXFLAGS= -Wall -g
LIBS=-ldasio -lnl -lpthread

IWG1SRC = IWG1.cc IWG1oui.cc
IWG1OBJ = ${addsuffix .o, ${basename $(IWG1SRC) } } 
IWG1TGT = IWG1

.PHONY : all clean

all : IWG1

$(IWG1TGT) : $(IWG1OBJ)
	$(LINK.cc) -o $(IWG1TGT) $(IWG1OBJ) $(LIBS)
IWG1oui.cc : IWG1.oui
	oui -o IWG1oui.cc IWG1.oui

clean :
	rm -f *.o IWG1oui.cc IWG1
