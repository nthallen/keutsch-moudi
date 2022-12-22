function dfs_out = rt_moudi(dfs)
% dfs = rt_moudi()
%   Create a data_fields object and setup all the buttons for realtime
%   plots
% dfs_out = rt_moudi(dfs)
%   Use the data_fields object and setup all the buttons for realtime plots
if nargin < 1
  dfs = data_fields('title', 'SABRE Moudi', ...
    'Color', [.8 .8 1], ...
    'h_leading', 8, 'v_leading', 2, ...
    'btn_fontsize', 12, ...
    'txt_fontsize', 12);
  context_level = dfs.rt_init;
else
  context_level = 1;
end
dfs.start_col;
dfs.plot('a', 'label', 'Algo', 'plots', {'asws'});
dfs.plot('asws','label','SW Stat','vars',{'SWStat'});
dfs.plot('dacsa', 'label', 'uDACS A', 'plots', {'dacsas','dacsaais','dacsat','dacsaain'});
dfs.plot('dacsas','label','Status','vars',{{'name','Fail','var_name','FailMode','bit_number',0},{'name','Mode','var_name','FailMode','bit_number',4}});
dfs.plot('dacsaais','label','AI Stat','vars',{'uDACS_A_status'});
dfs.plot('dacsat','label','Temps','vars',{'RPi_T','Amb_T','Rov1T','Rov2T','Rov3T','Rov4T','Rov5T'});
dfs.plot('dacsaain','label','AI N','vars',{'uDACS_A_N'});
dfs.plot('ms', 'label', 'MS5607', 'plots', {'msp','mst'});
dfs.plot('msp','label','P','vars',{'MS5607_P'});
dfs.plot('mst','label','T','vars',{'MS5607_T'});
dfs.plot('p', 'label', 'Pump', 'plots', {'pt','ps','ppv'});
dfs.plot('pt','label','Temps','vars',{'PumpT'});
dfs.plot('ps','label','Status','vars',{{'name','PumpCmd','var_name','PwrStat','bit_number',3}});
dfs.plot('ppv','label','Pump V','vars',{'PumpV'});
dfs.plot('m', 'label', 'Moudi', 'plots', {'mc','mstatus'});
dfs.plot('mc','label','Command','vars',{'MMcmd'});
dfs.plot('mstatus','label','Status','vars',{'MMstat'});
dfs.end_col;
dfs.start_col;
dfs.plot('tm', 'label', 'T Mbase', 'plots', {'tmtd','tmcpu','tmram','tmd'});
dfs.plot('tmtd','label','T Drift','vars',{'SysTDrift'});
dfs.plot('tmcpu','label','CPU','vars',{'CPU_Pct'});
dfs.plot('tmram','label','RAM','vars',{'memused'});
dfs.plot('tmd','label','Disk','vars',{'Disk'});
dfs.plot('ahk', 'label', 'Alicat HK', 'plots', {'ahks','ahkstale','ahkt','ahkmbar'});
dfs.plot('ahks','label','Status','vars',{'MMFC_Status'});
dfs.plot('ahkstale','label','Stale','vars',{'MMFC_Stale','Alicat_Stale'});
dfs.plot('ahkt','label','T','vars',{'MMFC_T'});
dfs.plot('ahkmbar','label','mbar','vars',{'MMFC_P'});
dfs.plot('alicat', 'label', 'Alicat', 'plots', {'alicatnccm','alicatccm'});
dfs.plot('alicatnccm','label','nccm','vars',{'MMFC_Set','MMFC_MassFlow'});
dfs.plot('alicatccm','label','ccm','vars',{'MMFC_VolFlow'});
dfs.end_col;
dfs.start_col;
dfs.plot('iwg', 'label', 'IWG1', 'plots', {'iwgl','iwglon','iwgt','iwgp','iwgs','iwgm','iwga'});
dfs.plot('iwgl','label','Lat','vars',{'Lat'});
dfs.plot('iwglon','label','Lon','vars',{'Lon'});
dfs.plot('iwgt','label','Temp','vars',{'Ambient_Temp','Total_Temp','Dew_Point'});
dfs.plot('iwgp','label','Pres','vars',{'Dynamic_Press','Static_Press'});
dfs.plot('iwgs','label','Speed','vars',{'Grnd_Spd','Indicated_Airspeed','True_Airspeed'});
dfs.plot('iwgm','label','Mach','vars',{'Mach_Number'});
dfs.plot('iwga','label','Alt','vars',{'GPS_MSL_Alt','Press_Alt','Radar_Alt','WGS_84_Alt'});
dfs.plot('attitude', 'label', 'Attitude', 'plots', {'attitudea','attitudep','attituder','attitudess','attituded','attitudesz','attitudeaz','attitude_az','attitudet'});
dfs.plot('attitudea','label','Attack','vars',{'Angle_of_Attack'});
dfs.plot('attitudep','label','Pitch','vars',{'Pitch'});
dfs.plot('attituder','label','Roll','vars',{'Roll'});
dfs.plot('attitudess','label','Side Slip','vars',{'Side_slip'});
dfs.plot('attituded','label','Drift','vars',{'Drift'});
dfs.plot('attitudesz','label','SZ','vars',{'Solar_Zenith','Sun_Elev_AC'});
dfs.plot('attitudeaz','label','AZ','vars',{'Sun_Az_AC'});
dfs.plot('attitude_az','label','Az','vars',{'Sun_Az_Grd'});
dfs.plot('attitudet','label','Track','vars',{'Track','True_Hdg'});
dfs.end_col;
dfs.start_col;
dfs.plot('w', 'label', 'Wind', 'plots', {'wvv','wvs','wd','ws'});
dfs.plot('wvv','label','Vert Vel','vars',{'Vert_Velocity'});
dfs.plot('wvs','label','Vert Speed','vars',{'Vert_Wind_Spd'});
dfs.plot('wd','label','Dir','vars',{'Wind_Dir'});
dfs.plot('ws','label','Speed','vars',{'Wind_Speed'});
dfs.plot('iwg1_stat', 'label', 'IWG1 Stat', 'plots', {'iwg1_statcp','iwg1_stattd','iwg1_stats'});
dfs.plot('iwg1_statcp','label','Cabin Press','vars',{'Cabin_Press'});
dfs.plot('iwg1_stattd','label','T Drift','vars',{'TDDrift','TDrift'});
dfs.plot('iwg1_stats','label','Stale','vars',{'IWG1_Stale'});
dfs.end_col;
dfs.resize(context_level);
dfs.set_connection('127.0.0.1', 1080);
if nargout > 0
  dfs_out = dfs;
end
