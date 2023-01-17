#ifndef UDPTXIN_INT_H_INCLUDED
#define UDPTXIN_INT_H_INCLUDED
#include "dasio/cmd_reader.h"
#include "dasio/tm_data_sndr.h"
#include "UDP.h"

using namespace DAS_IO;

class CR_UDPtx : public Cmd_reader {
  public:
    CR_UDPtx(const char *broadcast_ip, const char *broadcast_port);
    ~CR_UDPtx();
    bool app_input();
  protected:
    UDPbcast *UDPtx;
};

class UDPrx_TM : public Interface {
  public:
    UDPrx_TM(TM_data_sndr *tm, const char *port);
    bool protocol_input();
  private:
    void Bind(const char *port);
    int fillbuf();
    // int not_ndigits(int n, int &value);
    // int not_ISO8601(double *Time);
    // int not_nfloat(float *value);
    TM_data_sndr *tm;
};

#endif
