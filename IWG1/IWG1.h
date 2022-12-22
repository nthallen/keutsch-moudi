#ifndef IWG1_H_INCLUDED
#define IWG1_H_INCLUDED

#include <time.h>

// I usually pack structs used in interprocess (and possibly inter-architecture)
// communication, but by inspection, this should not require packing.
typedef struct {
  double Time;
  float Lat;
  float Lon;
  float GPS_MSL_Alt;
  float WGS_84_Alt;
  float Press_Alt;
  float Radar_Alt;
  float Grnd_Spd;
  float True_Airspeed;
  float Indicated_Airspeed;
  float Mach_Number;
  float Vert_Velocity;
  float True_Hdg;
  float Track;
  float Drift;
  float Pitch;
  float Roll;
  float Side_slip;
  float Angle_of_Attack;
  float Ambient_Temp;
  float Dew_Point;
  float Total_Temp;
  float Static_Press;
  float Dynamic_Press;
  float Cabin_Press;
  float Wind_Speed;
  float Wind_Dir;
  float Vert_Wind_Spd;
  float Solar_Zenith;
  float Sun_Elev_AC;
  float Sun_Az_Grd;
  float Sun_Az_AC;
} IWG1_data_t;

extern IWG1_data_t IWG1;

#endif
