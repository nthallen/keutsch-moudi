#ifndef UDP_H_INCLUDED
#define UDP_H_INCLUDED
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
// #include <sys/un.h>
#include <netdb.h>
#include <netinet/in.h>
#include "dasio/csv_file.h"

#define STATUS_Ready 1
#define STATUS_Operating 2
#define STATUS_Calibrating 4
#define STATUS_Warning 8
#define STATUS_Invalid 16
#define STATUS_Failed 32

#define TM_CLIENT_FAST true

class UDPbcast {
  public:
    UDPbcast(const char *broadcast_ip, const char *broadcast_port, int buflen = 128);
    ~UDPbcast();
    int Broadcast(const char *fmt, ...);
    const char *ISO8601(double utc);
    bool ok();
  private:
    int UDP_init();
    char *buf;
    int buflen;
    const char *broadcast_ip;
    const char *broadcast_port;
    int bcast_sock;
    bool ok_status;
    bool ov_status;
    struct sockaddr_in s;
    socklen_t addrlen;
    bool sendto_err_reported;
};

class UDPcsv_file : public csv_file {
  public:
    UDPcsv_file(unsigned int n_cols, const char *nan_text = 0);
    void init(UDPbcast *UDPb, int obufsize);
    void transmit(const char *hdr, double utime); // const char *iso8601);
  protected:
    UDPbcast *UDP;
    char *obuf;
    int obufsize;
    bool ovflow_reported;
    int n_ovflow;
};

extern bool UDPext_debug;

#endif
