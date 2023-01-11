/* SWData.h */
#ifndef SWDATA_H_INCLUDED
#define SWDATA_H_INCLUDED

typedef struct __attribute__((__packed__)) {
  unsigned char SWStat;
  unsigned char MoudiMode;
  uint16_t Sim_P;
} SWData_t;
extern SWData_t SWData;

#define SWS_TAKEOFF 1
#define SWS_LAND 4
#define SWS_TIME_WARP 253
#define SWS_SHUTDOWN 255
#define SWS_MOUDI_P_CTRL 0
#define SWS_MOUDI_I_OPEN 1
#define SWS_MOUDI_I_CLOSE 2

#endif
