function pmoudips(varargin);
% pmoudips( [...] );
% Pump Status
h = ne_dstat({
  'PumpCmd', 'PwrStat', 3 }, 'Status', varargin{:} );
