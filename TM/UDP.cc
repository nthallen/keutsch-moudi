#include <errno.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <unistd.h>
#include <stdarg.h>
#include "UDP.h"
#include "nl.h"
#include "nl_assert.h"

UDPbcast::UDPbcast(const char *broadcast_ip,
                   const char *broadcast_port,
                   int buflen)
    : buf(0),
      buflen(buflen),
      broadcast_ip(broadcast_ip),
      broadcast_port(broadcast_port),
      bcast_sock(-1),
      ok_status(false),
      ov_status(false),
      sendto_err_reported(false) {
  buf = new char[buflen];
  UDP_init();
}

/**
 * @return non-zero on error
 */
int UDPbcast::UDP_init() {
  if (!UDPext_debug) {
    bcast_sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (bcast_sock == -1) {
      msg(nl_response, "Unable to create UDP socket: %s", strerror(errno));
      return 1;
    }
    int broadcastEnable = 1;
    int ret = setsockopt(bcast_sock, SOL_SOCKET, SO_BROADCAST,
      &broadcastEnable, sizeof(broadcastEnable));
    if (ret == -1) {
      msg(nl_response, "setsockopt failed: %s", strerror(errno));
      return 1;
    }
    struct addrinfo hints, *res;
    hints.ai_flags = AI_NUMERICHOST;
    hints.ai_family = PF_INET;
    hints.ai_socktype = SOCK_DGRAM;
    hints.ai_protocol = IPPROTO_UDP;
    hints.ai_addrlen = 0;
    hints.ai_canonname = 0;
    hints.ai_addr = 0;
    hints.ai_next = 0;
    if (getaddrinfo(broadcast_ip, broadcast_port, &hints, &res)) {
      msg(nl_response, "getaddrinfo failed: %s", strerror(errno));
      return 1;
    }
    nl_assert(res->ai_next == 0);
    nl_assert(res->ai_addr != 0);
    nl_assert(((unsigned)res->ai_addrlen) <= sizeof(s));
    memcpy(&s, res->ai_addr, res->ai_addrlen);
    addrlen = res->ai_addrlen;
    freeaddrinfo(res);
  }
  ok_status = true;
  return 0;
}

UDPbcast::~UDPbcast() {
  if (bcast_sock != -1) {
    close(bcast_sock);
    bcast_sock = -1;
  }
  if (buf) {
    delete(buf);
    buf = 0;
  }
}

bool UDPbcast::ok() { return ok_status; }

/**
 * Example:
 *   UDP.Broadcast("HWV,%s,%d,%.2lf\r\n", ISO8601(utc), status, mr);
 * @return non-zero on error
 */
int UDPbcast::Broadcast(const char *fmt, ...) {
  if (UDPext_debug) return 0;
  if (!ok_status && UDP_init())
    return 1;
  va_list args;
  int msglen;
  va_start(args, fmt);
  msglen = vsnprintf(buf, buflen, fmt, args);
  va_end(args);
  if (msglen >= buflen) {
    if (!ov_status) {
      msg(2, "UDP Broadcast buffer overflow");
      ov_status = true;
    }
    return 1; // Don't broadcast a truncated message
  }
  if (ok_status) {
    int nb = sendto(bcast_sock, buf, msglen, 0, (sockaddr*)&s, addrlen);
    if (nb < 0) {
      if (!sendto_err_reported) {
        msg(2, "sendto() returned error %d: %s", errno, strerror(errno));
        sendto_err_reported = true;
      }
      ok_status = false;
      close(bcast_sock);
      bcast_sock = -1;
      return 1;
    } else if (nb < msglen) {
      if (!sendto_err_reported) {
        msg(2, "sendto() expected %d, returned %d", msglen, nb);
        sendto_err_reported = true;
      }
      return 1;
    } else if (sendto_err_reported) {
      msg(0, "sendto() succeeded");
      sendto_err_reported = false;
    }
  } else {
    return 1;
  }
  return 0;
}

const char *UDPbcast::ISO8601(double utc) {
  // yyyy-mm-ddThh:mm:ss.mmm
  static char buf[24];
  time_t iutc = floor(utc);
  double futc = utc - iutc;
  if (futc >= 1) {
    futc -= 1.0;
    ++iutc;
  } else if (futc < 0) {
    futc += 1.0;
    --iutc;
  }
  struct tm *tms = gmtime(&iutc);
  snprintf(buf, 24, "%4d-%02d-%02dT%02d:%02d:%06.3lf",
    tms->tm_year + 1900,
    tms->tm_mon + 1,
    tms->tm_mday,
    tms->tm_hour,
    tms->tm_min,
    tms->tm_sec + futc);
  return buf;
}

UDPcsv_file::UDPcsv_file(unsigned int n_cols, const char *nan_text)
    : csv_file("", n_cols, nan_text),
      UDP(0),
      obuf(0),
      obufsize(0),
      ovflow_reported(false),
      n_ovflow(0) {
}

void UDPcsv_file::init(UDPbcast *UDPb, int obufsize) {
  UDP = UDPb;
  this->obufsize = obufsize;
  obuf = new char[obufsize];
}

void UDPcsv_file::transmit(const char *hdr, double utime) {
  int nc = 0;
  nc += snprintf(&obuf[nc], obufsize-nc, "%s,%s", hdr, UDP->ISO8601(utime));
  for (unsigned int i = 1; i < cols.size(); ++i) {
    if (cols[i]) {
      nc += snprintf(&obuf[nc], obufsize-nc, ",%s", cols[i]->output());
      cols[i]->reset();
    } else if (nc+1 < obufsize) {
      obuf[nc++] = ',';
      obuf[nc] = '\0';
    } else ++nc;
  }
  nc += snprintf(&obuf[nc], obufsize-nc, "\r\n");
  if (nc < obufsize) {
    if (UDPext_debug)
      msg(0, "%s", obuf);
    else
      UDP->Broadcast("%s", obuf);
  } else {
    ++n_ovflow;
    if (!ovflow_reported) {
      msg(2, "UDP output buffer overflow: nc=%d", nc);
      ovflow_reported = true;
    }
  }
}
