#include "dasio/loop.h"
#include "UDPtxin.h"
#include "oui.h"
#include "nl.h"

using namespace DAS_IO;

bool UDPext_debug;

int main(int argc, char **argv) {
  oui_init_options(argc, argv);
  Loop ELoop;
  CR_UDPtx *CRxUtx = new CR_UDPtx("10.15.101.131", "7075");
  CRxUtx->connect();
  ELoop.add_child(CRxUtx);
  
  // UDPrx_TM *UrxTM = new UDPrx_TM("7075");
  // ELoop.add_child(UrxTM);
  
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
  UDPtx->Broadcast("%s", buf);
  report_ok(nc);
  return false;
}
