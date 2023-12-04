% function [outy, outax] = processing(y, inax)
% ax.filt       <'none'>/'rc'/'mvgaver'/'savgol'
% ax.filtpar1   <'auto'>/'1D'/'2D'/'1D2D'

function [outy, outax] = kv3_processing(y, inax)
if nargin < 2
  disp('Usage: [outy, outax] = processing(y, inax)');
  disp('Filter:')
  disp('ax.filt =      <''none''>/''rc''/''mvgaver''/''savgol''');
  disp('ax.filtpar1 =  <''auto''>/''1D''/''2D''/''1D2D''');
  disp('ax.tc = 1..n');
  disp('Pseudo modulation: ax.diff = <''diff''> and ax.ps_mod = 1..n')
  error('Wrong syntax.');
end
if isempty(y)
  outy=[]; outax=[];
  return;
end
filtproc = kv3_safeget(inax, 'filt', '');
diffintproc = kv3_safeget(inax, 'diff', '');
shift = kv3_safeget(inax,'s', 0);
filtx = 0; filty = 0;
switch filtproc
  case 'rc'
    sizey = size(y,1);
    cc = kv3_safeget(inax, 'tc', 5);
    y = rcfilt(y, 1, cc).';
  case 'mvgaver'
    cc = kv3_safeget(inax, 'tc', 5);
    fpar = kv3_safeget(inax, 'filtpar1', 'auto');
    if strcmp(fpar,'auto')
      filtx = 1;
      if size(y,2) > 5, filty = 1; end
    else
      if strfind(fpar, '1D'), filtx = 1; end
      if strfind(fpar, '2D'), filty = 1; end
    end
    if filtx, y = kv_mvgavg(y, cc, 'binom'); end
    if filty, y = kv_mvgavg(y.', cc, 'binom').'; end
  case 'savgol'
    cc   = kv3_safeget(inax, 'tc', 5);
    cc1  = kv3_safeget(inax, 'pol', 2);
    fpar = kv3_safeget(inax, 'filtpar1', 'auto');
    if strcmp(fpar,'auto')
      filtx = 1;
      if size(y,2) > 5, filty = 1; end
    else
      if strfind(fpar, '1D'), filtx = 1; end
      if strfind(fpar, '2D'), filty = 1; end
    end
    if filtx, y = kv_mvgavg(y, cc, 'savgol', cc1); end
    if filty, y = kv_mvgavg(y.', cc, 'savgol', cc1).'; end
  otherwise
end
switch diffintproc
  case 'diff'
    sizey = size(y,1);
    bl = sum(y([1:4,end-3:end],:))/8;
    cc = kv3_safeget(inax, 'ps_mod', 5);
    for k = 1:size(y,2)
      y(:,k) = fieldmod((1:sizey)', real(y(:,k)-bl(1,k)).', cc).';
    end
  case 'integr'
    % alsi 07.01.2004
    sizey = size(y,1);

    % boep for cw is better:
    bl = mean(y);
    %     bl = sum(y([1:4,end-3:end],:))/8;

    sizey = size(y, 2);
    % a bit rough but enougth for viewing
    for k = 1:sizey
      y(:, k) = cumsum(y(:, k)-bl(1,k));
    end
    y = y.*(inax.x(2) - inax.x(1))/2;
  otherwise
end
outax = inax;
outax.filt = '';
outax.diff = '';
outy = y + shift;
