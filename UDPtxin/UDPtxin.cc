#include <netdb.h>
#include <arpa/inet.h>
#include <errno.h>
#include <string.h>
#include "dasio/loop.h"
#include "UDPtxin_int.h"
#include "UDPtxin.h"
#include "oui.h"
#include "nl.h"


using namespace DAS_IO;

bool UDPext_debug;
UDPtxin_t UDPtxin;

int main(int argc, char **argv) {
  oui_init_options(argc, argv);
  Loop ELoop;
  CR_UDPtx *CRxUtx = new CR_UDPtx("10.15.101.131", "7075");
  CRxUtx->connect();
  ELoop.add_child(CRxUtx);
  
  TM_data_sndr *tm =
      new TM_data_sndr("TM", 0, "UDPtxin", &UDPtxin, sizeof(UDPtxin_t));
  ELoop.add_child(tm);
  tm->connect();

  UDPrx_TM *UrxTM = new UDPrx_TM(tm, "7075");
  ELoop.add_child(UrxTM);
  
  msg(0, "Started");
  ELoop.event_loop();
  ELoop.delete_children();
  ELoop.clear_delete_queue(true);
  msg(MSG, "Terminating");
  return 0;
}

/**
 * The Cmd_reader Command channel "UDPCmdTx" is specified in
 * TM/Moudi.cmd.
 */
CR_UDPtx::CR_UDPtx(const char *broadcast_ip, const char *broadcast_port)
    : Cmd_reader("UDPtx", 200, "UDPCmdTx") {
  UDPtx = new UDPbcast(broadcast_ip, broadcast_port);
}

CR_UDPtx::~CR_UDPtx() {
  if (UDPtx) {
    delete(UDPtx);
    UDPtx = 0;
  }
}

/**
 * Receives commands from txsrvr and forwards them to a UDP address
 */
bool CR_UDPtx::app_input() {
  if (nc >= 1 && buf[0] == 'Q' && buf[1] == '\0') {
    return true;
  }
  msg(0, "Relaying: %s", buf);
  UDPtx->Broadcast("%s", buf);
  report_ok(nc);
  return false;
}

UDPrx_TM::UDPrx_TM(TM_data_sndr *tm, const char *port)
    : Interface("UDP", 600 ),
      tm(tm) {
  // Set up UDP listener
  Bind(port);
  flags = Fl_Read;
  // flush_input();
  setenv("TZ", "UTC0", 1); // Force UTC for mktime()
}

bool UDPrx_TM::protocol_input() {
  uint16_t status;
  if (not_str( "MOUDI," ) ||
      not_ISO8601(UDPtxin.Time) || not_str( ",", 1) ||
      not_uint16(status) || not_str(",", 1) ||
      not_uint8(UDPtxin.ValveS) || not_str( ",", 1) ||
      not_uint16(UDPtxin.MoudiFlow) || not_str( ",", 1) ||
      not_uint8(UDPtxin.PumpS) || not_str( ",", 1) ||
      not_float(UDPtxin.PumpV) || not_str( ",", 1) ||
      not_float(UDPtxin.PumpT) || not_str( ",", 1) ||
      not_float(UDPtxin.InstP) || not_str( ",", 1) ||
      not_float(UDPtxin.InstT)) {
    if (cp < nc) {
      consume(nc); // syntax error (already reported). Empty
    } // else cp == nc, so it was a partial record. See if we will get more.
    return 0;
  }
  UDPtxin.InstS = status % 10;
  UDPtxin.AlgoS = status / 10;
  tm->Send();
  report_ok(nc);
  return 0;
}

void UDPrx_TM::Bind(const char *port) {
	struct addrinfo hints,*results, *p;
  int err, ioflags;

	if (port == 0)
    msg(MSG_FATAL, "Invalid port in UDPrx_TM: 0" );

	memset(&hints, 0, sizeof(hints));	
	hints.ai_family = AF_UNSPEC;		// don't care IPv4 of v6
	hints.ai_socktype = SOCK_DGRAM;
	hints.ai_flags = AI_PASSIVE;
	
	err = getaddrinfo(NULL, 
						port,
						&hints,
						&results);
	if (err)
    msg(MSG_FATAL, "UDPrx_TM::Bind: getaddrinfo error: %s", gai_strerror(err) );
	for(p=results; p!= NULL; p=p->ai_next) {
		fd = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
		if (fd < 0)
      msg(MSG_ERROR, "UDPrx_TM::Bind: socket error: %s", strerror(errno) );
		else if ( bind(fd, p->ai_addr, p->ai_addrlen) < 0 )
      msg(MSG_ERROR, "UDPrx_TM::Bind: bind error: %s", strerror(errno) );
		else break;
	}
  if (fd < 0)
    msg(MSG_FATAL, "Unable to bind UDP socket");
    
  ioflags = fcntl(fd, F_GETFL, 0);
  if (ioflags != -1)
    ioflags = fcntl(fd, F_SETFL, ioflags | O_NONBLOCK);
  if (ioflags == -1)
    msg(MSG_FATAL, "Error setting O_NONBLOCK on UDP socket: %s",
      strerror(errno));
}

int UDPrx_TM::fillbuf() {
	struct sockaddr_storage from;
	socklen_t fromlen = sizeof(from);
	int rv = recvfrom(fd, &buf[nc],	bufsize - nc - 1, 0,
						(struct sockaddr*)&from, &fromlen);
	
	if (rv == -1) {
    if ( errno == EWOULDBLOCK ) {
      ++n_eagain;
    } else if (errno == EINTR) {
      ++n_eintr;
    } else {
      msg(MSG_ERROR, "UDPrx_TM::fillbuf: recvfrom error: %s", strerror(errno));
      return 1;
    }
    return 0;
  }
  nc += rv;
  buf[nc] = '\0';
  return 0;
}
