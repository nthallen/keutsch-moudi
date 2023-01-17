#ifndef UDPTXIN_INT_H_INCLUDED
#define UDPTXIN_INT_H_INCLUDED
#include "dasio/cmd_reader.h"
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

#endif
