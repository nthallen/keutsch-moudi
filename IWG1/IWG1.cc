#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <errno.h>

#include "dasio/loop.h"
#include "dasio/quit.h"
#include "dasio/appid.h"
#include "nl.h"
#include "oui.h"
#include "IWG1_int.h"

IWG1_data_t IWG1;

int main(int argc, char **argv) {
  oui_init_options(argc, argv);
  { Loop L;
    TM_data_sndr *tm =
      new TM_data_sndr("TM", 0, "IWG1", &IWG1, sizeof(IWG1_data_t));
    L.add_child(tm);
    tm->connect();
    
    IWG1_UDP *IWG1 = new IWG1_UDP(tm);
    L.add_child(IWG1);
    
    Quit *Q = new Quit();
    L.add_child(Q);
    Q->connect();

    msg(MSG, "Starting: %s", AppID.rev);
    L.event_loop();
  }
  msg(MSG, "Terminating");
}

IWG1_UDP::IWG1_UDP(TM_data_sndr *tm)
    : Interface("UDP", 600 ),
      tm(tm) {
  // Set up UDP listener
  Bind(7071);
  flags = Fl_Read;
  // flush_input();
  setenv("TZ", "UTC0", 1); // Force UTC for mktime()
}

bool IWG1_UDP::protocol_input() {
  if (not_str( "IWG1," ) ||
      not_ISO8601(&IWG1.Time) || not_str( ",", 1) ||
      not_nfloat(&IWG1.Lat) || not_str(",", 1) ||
      not_nfloat(&IWG1.Lon) || not_str(",", 1) ||
      not_nfloat(&IWG1.GPS_MSL_Alt) || not_str(",", 1) ||
      not_nfloat(&IWG1.WGS_84_Alt) || not_str(",", 1) ||
      not_nfloat(&IWG1.Press_Alt) || not_str(",", 1) ||
      not_nfloat(&IWG1.Radar_Alt) || not_str(",", 1) ||
      not_nfloat(&IWG1.Grnd_Spd) || not_str(",", 1) ||
      not_nfloat(&IWG1.True_Airspeed) || not_str(",", 1) ||
      not_nfloat(&IWG1.Indicated_Airspeed) || not_str(",", 1) ||
      not_nfloat(&IWG1.Mach_Number) || not_str(",", 1) ||
      not_nfloat(&IWG1.Vert_Velocity) || not_str(",", 1) ||
      not_nfloat(&IWG1.True_Hdg) || not_str(",", 1) ||
      not_nfloat(&IWG1.Track) || not_str(",", 1) ||
      not_nfloat(&IWG1.Drift) || not_str(",", 1) ||
      not_nfloat(&IWG1.Pitch) || not_str(",", 1) ||
      not_nfloat(&IWG1.Roll) || not_str(",", 1) ||
      not_nfloat(&IWG1.Side_slip) || not_str(",", 1) ||
      not_nfloat(&IWG1.Angle_of_Attack) || not_str(",", 1) ||
      not_nfloat(&IWG1.Ambient_Temp) || not_str(",", 1) ||
      not_nfloat(&IWG1.Dew_Point) || not_str(",", 1) ||
      not_nfloat(&IWG1.Total_Temp) || not_str(",", 1) ||
      not_nfloat(&IWG1.Static_Press) || not_str(",", 1) ||
      not_nfloat(&IWG1.Dynamic_Press) || not_str(",", 1) ||
      not_nfloat(&IWG1.Cabin_Press) || not_str(",", 1) ||
      not_nfloat(&IWG1.Wind_Speed) || not_str(",", 1) ||
      not_nfloat(&IWG1.Wind_Dir) || not_str(",", 1) ||
      not_nfloat(&IWG1.Vert_Wind_Spd) || not_str(",", 1) ||
      not_nfloat(&IWG1.Solar_Zenith) || not_str(",", 1) ||
      not_nfloat(&IWG1.Sun_Elev_AC) || not_str(",", 1) ||
      not_nfloat(&IWG1.Sun_Az_Grd) || not_str(",", 1) ||
      not_nfloat(&IWG1.Sun_Az_AC)) {
    if (cp < nc) {
      nc = cp = 0; // syntax error (already reported). Empty
    } // else cp == nc, so it was a partial record. See if we will get more.
    return 0;
  }
  tm->Send();
  report_ok(nc);
  return 0;
}

int IWG1_UDP::not_ndigits(int n, int &value) {
  int i = n;
  value = 0;
  while ( i > 0 && cp < nc && isdigit(buf[cp])) {
    value = value*10 + buf[cp++] - '0';
    --i;
  }
  if (i > 0) {
    if (cp < nc)
      report_err("Expected %d digits at column %d", n, cp-i);
    return 1;
  }
  return 0;
}

int IWG1_UDP::not_ISO8601(double *Time) {
  struct tm buft;
  float secs;
  time_t ltime;

  if (not_ndigits(4, buft.tm_year) ||
      not_str("-",1) ||
      not_ndigits(2, buft.tm_mon) ||
      not_str("-",1) ||
      not_ndigits(2, buft.tm_mday) ||
      not_str("T", 1) ||
      not_ndigits(2, buft.tm_hour) ||
      not_str(":",1) ||
      not_ndigits(2, buft.tm_min) ||
      not_str(":",1) ||
      not_float(secs))
    return 1;
  buft.tm_year -= 1900;
  buft.tm_mon -= 1;
  buft.tm_sec = 0;
  buft.tm_isdst = 0;
  ltime = mktime(&buft);
  if (ltime == (time_t)(-1))
    report_err("mktime returned error");
  else *Time = (double)ltime + secs;
  return 0;
}

/**
 * accept a float or return a NaN (99999.)
 * if the next char is a comma or CR
 */
int IWG1_UDP::not_nfloat(float *value) {
  float val;
  while (cp < nc && buf[cp] == ' ') ++cp;
  if (cp >= nc) return 1;
  if (buf[cp] == ',' || buf[cp] == '\r' || buf[cp] == '\n') {
    *value = 99999.;
    return 0;
  }
  if (not_float(val)) return 1;
  *value = val;
  return 0;
}

void IWG1_UDP::Bind(int port) {
	char service[10];
	struct addrinfo hints,*results, *p;
  int err, ioflags;

	if (port == 0)
    msg(MSG_FATAL, "Invalid port in IWG1_UDP: 0" );
	snprintf(service, 10, "%d", port);

	memset(&hints, 0, sizeof(hints));	
	hints.ai_family = AF_UNSPEC;		// don't care IPv4 of v6
	hints.ai_socktype = SOCK_DGRAM;
	hints.ai_flags = AI_PASSIVE;
	
	err = getaddrinfo(NULL, 
						service,
						&hints,
						&results);
	if (err)
    msg(MSG_FATAL, "IWG1_UDP::Bind: getaddrinfo error: %s", gai_strerror(err) );
	for(p=results; p!= NULL; p=p->ai_next) {
		fd = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
		if (fd < 0)
      msg(MSG_ERROR, "IWG1_UPD::Bind: socket error: %s", strerror(errno) );
		else if ( bind(fd, p->ai_addr, p->ai_addrlen) < 0 )
      msg(MSG_ERROR, "IWG1_UDP::Bind: bind error: %s", strerror(errno) );
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

int IWG1_UDP::fillbuf() {
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
      msg(MSG_ERROR, "IWG1_UDP::fillbuf: recvfrom error: %s", strerror(errno));
      return 1;
    }
    return 0;
  }
  nc += rv;
  buf[nc] = '\0';
  return 0;
}
