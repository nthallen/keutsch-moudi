%INTERFACE <Alicat>

%{
  #ifdef SERVER
  void Alicat_set(int ID, float setpoint) {
    uint32_t rawset = *(uint32_t*)&setpoint;
    // WII:FF:AAAA:NN:DD:DD...

    // II is the device ID
    // FF is the Modbus function code
    // AA is the register address
    // NN is the number of registers
    // DD are the register values
    // All values are in hex
    if_Alicat.Turf("W%X:%X:%X:2:%X:%X\n",
      ID, 16, 1009, ((rawset>>16) & 0xFFFF),
      (rawset & 0xFFFF));
  }
  #endif
%}

&command
  : MFC Moudi Flow SetPoint %f (ccm) ccm * { Alicat_set(1, $5); }
  ;
