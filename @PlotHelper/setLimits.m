function setLimits()
    currentXLim = xlim; xRange = currentXLim(2) - currentXLim(1);
    currentYLim = ylim; yRange = currentYLim(2) - currentYLim(1);
    %currentXLim = gca
    currentXScale = get(gca, 'XScale');
    switch currentXScale
        case 'linear'
            newXLim = 0.05*[-xRange xRange] + currentXLim;
        case 'log'
            newXLim = power(10, 0.05*[-log10(xRange) log10(xRange)] + log10(currentXLim));
    end
    currentYScale = get(gca, 'YScale');
    switch currentYScale
        case 'linear'
            newYLim = 0.04*[-yRange yRange] + currentYLim;
        case 'log'
            newYLim = power(10, 0.05*[-log10(yRange) log10(yRange)] + log10(currentYLim));
    end

    xlim(newXLim);
    ylim(newYLim);
end