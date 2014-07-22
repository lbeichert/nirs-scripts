function [] = printFigure( figureHandle, path )
%PRINTFIGURE prints figure as landscape pdf and png

set(figureHandle, 'PaperOrientation', 'landscape');
set(figureHandle,'PaperUnits','normalized');
set(figureHandle,'PaperPosition', [0 0 1 1]);
print(figureHandle, '-dpdf', path);
print(figureHandle, '-dpng', path);

end

