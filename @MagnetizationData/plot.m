function plot(obj, varargin)
    p = inputParser;
    argName = 'plot_type';
    defaultVal = 'm';
    p.addOptional(argName, defaultVal, @ischar);
    p.addParameter('Spacing', 1);
    p.parse(varargin{:});

    labels{1} = 'Field (T)';
    data_group = obj.Parsed.TemperatureRounded;
    switch p.Results.plot_type
        case 'm'
            xdata = obj.Parsed.Field ./ 10000;
            ydata = obj.Parsed.Moment;
            labels{2} = 'Moment (emu)';
        case 'mmass'
            xdata = obj.Parsed.Field ./ 10000;
            ydata = obj.Parsed.MomentMass;
            labels{2} = 'Moment (emu/g)';
        case 'meff'
            xdata = obj.Parsed.Field ./ 10000;
            ydata = obj.Parsed.MomentEff;
            labels{2} = 'Magnetization (\mu_B/mol)';
        otherwise
            display('Unrecognized plot type, supported: m (emu), mmass (emu/gram), meff (uB/mol)');
            return;
    end

    PlotHelper.plotDataset(xdata, ydata, data_group, 'line', p.Results.Spacing, 'o');
    xlabel(labels{1}); ylabel(labels{2});
end