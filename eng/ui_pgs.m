function ui_pgs
f = ne_dialg('SABRE MOUDI PGS',1);
f = ne_dialg(f, 'add', 0, 1, 'gpgstm', 'T Mbase' );
f = ne_dialg(f, 'add', 1, 0, 'ppgstmtd', 'T Drift' );
f = ne_dialg(f, 'add', 1, 0, 'ppgstmcpu', 'CPU' );
f = ne_dialg(f, 'add', 1, 0, 'ppgstmram', 'RAM' );
f = ne_dialg(f, 'add', 1, 0, 'ppgstmd', 'Disk' );
f = ne_dialg(f, 'add', 0, 1, 'gpgss', 'Status' );
f = ne_dialg(f, 'add', 1, 0, 'ppgsss', 'Stale' );
f = ne_dialg(f, 'add', 1, 0, 'ppgssd', 'Drift' );
f = ne_dialg(f, 'add', 1, 0, 'ppgssstatus', 'Status' );
f = ne_dialg(f, 'add', 1, 0, 'ppgssa', 'Algo' );
f = ne_dialg(f, 'add', 1, 0, 'ppgssv', 'Valve' );
f = ne_dialg(f, 'add', 1, 0, 'ppgssp', 'Pump' );
f = ne_dialg(f, 'add', 0, 1, 'gpgsa', 'Analog' );
f = ne_dialg(f, 'add', 1, 0, 'ppgsaf', 'Flow' );
f = ne_dialg(f, 'add', 1, 0, 'ppgsat', 'Temp' );
f = ne_dialg(f, 'add', 1, 0, 'ppgsap', 'Pres' );
f = ne_dialg(f, 'add', 1, 0, 'ppgsaat', 'Amb T' );
f = ne_listdirs(f, 'MOUDI_PGS_DATA_DIR', 15);
f = ne_dialg(f, 'newcol');
ne_dialg(f, 'resize');
