#ifndef IWG1_INT_H_INCLUDED
#define IWG1_INT_H_INCLUDED

#include <math.h>
#include "dasio/interface.h"
#include "dasio/tm_data_sndr.h"
#include "IWG1.h"

using namespace DAS_IO;

class IWG1_UDP : public Interface {
  public:
    IWG1_UDP(TM_data_sndr *tm);
    bool protocol_input();
  private:
    void Bind(int port);
    int fillbuf();
    int not_ndigits(int n, int &value);
    int not_ISO8601(double *Time);
    int not_nfloat(float *value);
    TM_data_sndr *tm;
};

#endif

// Port 5101 just IWG1 packets
// Port 7071 is the standard port, but for historical reasons, DC-8 uses 5101 as the primary.
// Instrument data comes on port 5110 in a format similar to IWG1:
// InstMnc,TIME,data,data,data,...,\r\n
