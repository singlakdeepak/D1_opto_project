% set OS details and set path

if ispc
    disp('Running on Windows');
    osid = 1;
elseif isunix
    disp('Running on Linux/Unix (e.g., Ubuntu)');
    osid = 2;
elseif ismac
    disp('Running on macOS');
    osid = 2;
end
if (osid ==1)
    addpath(genpath('..\Code\VLSE neuro\'));
elseif (osid == 2)
    addpath(genpath('../'));
end