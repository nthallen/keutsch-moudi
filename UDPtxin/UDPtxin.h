#ifndef UDPTXIN_H_INCLUDED
#define UDPTXIN_H_INCLUDED

// This has been rearranged to work without packing
typedef struct {
  double Time;
  float PumpV; // %4.2lf
  float PumpT; // %5.1lf
  float InstP; // %8.3lf
  float InstT; // %7.3lf
  float MoudiFlow;
  uint8_t InstS;
  uint8_t AlgoS;
  uint8_t ValveS;
  uint8_t PumpS;
} UDPtxin_t;

extern UDPtxin_t UDPtxin;

#endif

