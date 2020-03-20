function plotSusceptibility(obj)
    xdata = obj.Parsed.Temperature;
    ydata = obj.Parsed.ChiT;

    PlotHelper.plotDataset(xdata, ydata, obj.Parsed.Field, 'scatter', 1, 'o');
    PlotHelper.setLimits();
    xlabel('Temperature (K)'); ylabel('\chiT (emu mol^{-1} K)');
end