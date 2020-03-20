function plotDataset(x, y, group, plotType, colorSpacing, marker, varargin)
    if isempty(x) || isempty(y), return; end
    PlotHelper.setDefaults();
    p = inputParser;
    p.addParameter('Axes', gca);
    p.parse(varargin{:});
    groups = unique(group);
    toggle = double(~mod(colorSpacing+(0:length(groups)-1), colorSpacing));
    
    for a = 1:length(groups)
        rows = group == groups(a);
        switch plotType
            case 'scatter'
                scatter(p.Results.Axes, x(rows), y(rows), [], PlotHelper.colorFunction(groups(a), toggle(a)), 'filled', marker, 'MarkerFaceAlpha', PlotHelper.colorAlpha + (1 - PlotHelper.colorAlpha)*toggle(a));
            case 'line'
                currentPlot = plot(p.Results.Axes, x(rows), y(rows), 'Color', PlotHelper.colorFunction(groups(a), toggle(a)));
                currentPlot.Color(4) = PlotHelper.colorAlpha + (1 - PlotHelper.colorAlpha)*toggle(a);
        end
    end
end