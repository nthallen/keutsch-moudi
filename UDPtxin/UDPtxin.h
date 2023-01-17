#ifndef UDPTXIN_H_INCLUDED
#define UDPTXIN_H_INCLUDED

typedef struct {
  double Time;
  uint8_t InstS;
  uint8_t AlgoS;
  uint8_t ValveS;
  uint16_t MoudiFlow;
  uint8_t PumpS;
  uint16_t PumpV; // %4.2lf
  int16_t PumpT; // %5.1lf
  float InstP; // %8.3lf
  float InstT; // %7.3lf
} UDPtxin_t;

extern UDPtxin_t UDPtxin;

#endif

