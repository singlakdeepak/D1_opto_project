set(gca, 'XColor', 'k', 'YColor', 'k')  %changes axis color
set(gca, 'box', 'off')   
% set(gcf, 'color', 'w');    %sets the background color to white
if exist('fontSizeNew','var')
    set(gca,'FontSize',fontSizeNew,'TickDir','out')
else
    set(gca,'FontSize',12,'TickDir','out')
end
H=findobj(gca,'Type','text');
 set(H,'Rotation',0); % tilt

axes = findobj(gcf, 'type', 'axes');
for a = 1:length(axes)
    if axes(a).YColor < [1 1 1]
        axes(a).YColor = [0 0 0];
    end
    if axes(a).XColor < [1 1 1]
        axes(a).XColor = [0 0 0];
    end
    if exist('lineWeight','var')
        axes(a).XAxis.LineWidth = lineWeight;
        axes(a).YAxis.LineWidth = lineWeight;
    else
        axes(a).XAxis.LineWidth = 1;
        axes(a).YAxis.LineWidth = 1;
    end
    
end
if exist('nosqr','var')
    if nosqr == 0
        axis square
    end
else
    axis square
end
set(gca,'TickDir', 'out', 'TickLength',[0.02, 0.02])