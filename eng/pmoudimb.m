function pmoudimb(varargin)
% pmoudimb( [...] );
% Moudi Bypass
h = ne_dstat({
  'MM_BPV', 'PwrStat', 8 }, 'Bypass', varargin{:} );
