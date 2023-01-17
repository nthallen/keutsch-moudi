#include "UDPrx.h"
#include "dasio/cmd_writer.h"
#include "nl.h"
#include <string.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <errno.h>

UDPrx::UDPrx()
    : Interface("UDPrx", 600 ) {
  // Set up UDP listener
  Bind(7075); // As assigned for SABRE Mission
  flags = Fl_Read;
  // setenv("TZ", "UTC0", 1); // Force UTC for mktime()
  if (cic_init())
    msg(MSG_ERROR, "Unable to connect to command server");
}


bool UDPrx::protocol_input() {
  // Process incoming command
  // Could check for CMDREP_QUIT, but might be better to
  // let the TM_client take us out
  ci_sendcmd(Cmd_Send, (const char *)buf);
  report_ok(nc);
  return false;
}

void UDPrx::Bind(int port) {
	char service[10];
	struct addrinfo hints,*results, *p;
  int err, ioflags;

	if (port == 0)
    msg(MSG_FATAL, "Invalid port in UDPrx: 0" );
	snprintf(service, 10, "%d", port);

	memset(&hints, 0, sizeof(hints));	
	hints.ai_family = AF_UNSPEC;		// don't care IPv4 or v6
	hints.ai_socktype = SOCK_DGRAM;
	hints.ai_flags = AI_PASSIVE;
	
	err = getaddrinfo(NULL,
						service,
						&hints,
						&results);
	if (err)
    msg(MSG_FATAL, "UDPrx::Bind: getaddrinfo error: %s", gai_strerror(err) );
	for(p=results; p!= NULL; p=p->ai_next) {
		fd = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
		if (fd < 0)
      msg(MSG_ERROR, "IWG1_UPD::Bind: socket error: %s", strerror(errno) );
		else if ( bind(fd, p->ai_addr, p->ai_addrlen) < 0 )
      msg(MSG_ERROR, "UDPrx::Bind: bind error: %s", strerror(errno) );
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

int UDPrx::fillbuf() {
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
      msg(MSG_ERROR, "UDPrx::fillbuf: recvfrom error: %s", strerror(errno));
      return 1;
    }
    return 0;
  }
  nc += rv;
  buf[nc] = '\0';
  return 0;
}

void UDPrxext_tm_client::process_quit() {
  msg(MSG, "%s: process_quit()", iname);
  ELoop->set_loop_exit();
}

void UDPrxext_tm_client::adopted() {
  UDPrx *cmdrx_if = new UDPrx();
  ELoop->add_child(cmdrx_if);
}
