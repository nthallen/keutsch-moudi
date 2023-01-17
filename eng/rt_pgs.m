function dfs_out = rt_pgs(dfs)
% dfs = rt_pgs()
%   Create a data_fields object and setup all the buttons for realtime
%   plots
% dfs_out = rt_pgs(dfs)
%   Use the data_fields object and setup all the buttons for realtime plots
if nargin < 1
  dfs = data_fields('title', 'SABRE MOUDI PGS', ...
    'Color', [.8 .8 1], ...
    'h_leading', 8, 'v_leading', 2, ...
    'btn_fontsize', 12, ...
    'txt_fontsize', 12);
  context_level = dfs.rt_init;
else
  context_level = 1;
end
dfs.start_col;
dfs.plot('tm', 'label', 'T Mbase', 'plots', {'tmtd','tmcpu','tmram','tmd'});
dfs.plot('tmtd','label','T Drift','vars',{'SysTDrift'});
dfs.plot('tmcpu','label','CPU','vars',{'CPU_Pct'});
dfs.plot('tmram','label','RAM','vars',{'memused'});
dfs.plot('tmd','label','Disk','vars',{'Disk'});
dfs.plot('s', 'label', 'Status', 'plots', {'ss','sd','sstatus','sa','sv','sp'});
dfs.plot('ss','label','Stale','vars',{'UDPtxin_Stale'});
dfs.plot('sd','label','Drift','vars',{'UDPdrift'});
dfs.plot('sstatus','label','Status','vars',{'InstS'});
dfs.plot('sa','label','Algo','vars',{'AlgoS'});
dfs.plot('sv','label','Valve','vars',{'ValveS'});
dfs.plot('sp','label','Pump','vars',{'PumpS'});
dfs.plot('a', 'label', 'Analog', 'plots', {'af','at','ap','aat'});
dfs.plot('af','label','Flow','vars',{'MoudiFlow'});
dfs.plot('at','label','Temp','vars',{'PumpT'});
dfs.plot('ap','label','Pres','vars',{'InstP'});
dfs.plot('aat','label','Amb T','vars',{'InstT'});
dfs.end_col;
dfs.resize(context_level);
dfs.set_connection('127.0.0.1', 1080);
if nargout > 0
  dfs_out = dfs;
end
