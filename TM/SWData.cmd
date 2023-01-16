%{
  #include "SWData.h"
  #ifdef SERVER
    SWData_t SWData;
  #endif
%}

%INTERFACE <SWData:DG/data>

&^command
  : &SWTM * { if_SWData.Turf(); }
  ;
&SWTM
  : SW Status &SWStat { SWData.SWStat = $3; }
  : SW MOUDI &MoudiMode { SWData.MoudiMode = $3; }
  : Set Simulated Pressure &Sim_P { SWData.Sim_P = $4; }
  ;
&SWStat <unsigned char>
  : Altitude Takeoff { $0 = SWS_TAKEOFF; }
  : Set %d { $0 = $2; }
  : Altitude Land { $0 = SWS_LAND; }
  : Time Warp { $0 = SWS_TIME_WARP; }
  : Shutdown { $0 = SWS_SHUTDOWN; }
  ;
&MoudiMode <unsigned char>
  : Pressure Control { $0 = SWS_MOUDI_P_CTRL; }
  : Set %d { $0 = $2; }
  : Open { $0 = SWS_MOUDI_I_OPEN; }
  : Close { $0 = SWS_MOUDI_I_CLOSE; }
  ;
&Sim_P <uint16_t>
  : %d (Enter pressure in mbar) mbar { $0 = $1 < 0 ? 0 : $1; }
  ;
