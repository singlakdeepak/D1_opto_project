function SetFigBoxDefaults(fontSizeNew, lineWeight, nosqr, legendFontSize)
% SetFigBoxDefaults - Standardize figure aesthetics across all subplots and figure
%
% Optional inputs:
%   fontSizeNew     : numeric, font size (default = 12)
%   lineWeight      : numeric, axis line width (default = 1)
%   nosqr           : 0 to force square axes, 1 to skip (default = 1)
%   legendFontSize  : numeric, font size for legend (default = same as fontSizeNew)
%                     If empty or 0, legend font is not modified.

if nargin < 1 || isempty(fontSizeNew)
    fontSizeNew = 12;
end
if nargin < 2 || isempty(lineWeight)
    lineWeight = 1;
end
if nargin < 3 || isempty(nosqr)
    nosqr = 1; % default = don’t force square
end
if nargin < 4
    legendFontSize = fontSizeNew;
end

% --- Update axes ---
axesHandles = findobj(gcf, 'type', 'axes');

for a = 1:length(axesHandles)
    ax = axesHandles(a);

    % Axis colors
    ax.XColor = [0 0 0];
    ax.YColor = [0 0 0];

    % Axis line width
    ax.XAxis.LineWidth = lineWeight;
    ax.YAxis.LineWidth = lineWeight;

    % Fonts
    ax.FontSize   = fontSizeNew;
    ax.FontWeight = 'bold';
    ax.TickDir    = 'out';
    ax.TickLength = [0.02 0.02];

    % Force ticks only on bottom + left
    ax.Box = 'off';                % remove top/right box lines & ticks
    ax.XAxisLocation = 'bottom';   % x-axis ticks bottom only
    ax.YAxisLocation = 'left';     % y-axis ticks left only

    % Labels and titles
    if ~isempty(ax.XLabel.String)
        ax.XLabel.FontWeight = 'bold';
        ax.XLabel.FontSize   = fontSizeNew;
    end
    if ~isempty(ax.YLabel.String)
        ax.YLabel.FontWeight = 'bold';
        ax.YLabel.FontSize   = fontSizeNew;
    end
    if ~isempty(ax.Title.String)
        ax.Title.FontWeight = 'bold';
        ax.Title.FontSize   = fontSizeNew;
    end

    % Optional square axes
    if nosqr == 0
        axis(ax, 'square')
    end

    % Update legend if it exists and legendFontSize is nonzero
    if ~isempty(legendFontSize) && legendFontSize > 0
        lgd = legend(ax);
        if ~isempty(lgd) && isgraphics(lgd)
            lgd.FontSize   = legendFontSize;
            lgd.FontWeight = 'bold';
        end
    end
end
end
