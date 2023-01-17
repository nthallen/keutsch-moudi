function fig = gpgsa(varargin);
% gpgsa(...)
% Analog
ffig = ne_group(varargin,'Analog','ppgsaf','ppgsat','ppgsap','ppgsaat');
if nargout > 0 fig = ffig; end
