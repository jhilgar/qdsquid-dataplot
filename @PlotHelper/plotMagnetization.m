function plotMagnetization(obj)
    xdata = obj.Parsed.Field;
    ydata = obj.Parsed.Moment;

    PlotHelper.plotDataset(xdata ./ 10000, ydata, obj.Parsed.TemperatureRounded, 'line', 1);
    PlotHelper.setLimits();
    xlabel('Field (T)'); ylabel('Magnetization (\mu_{B} mol^{-1})');
end