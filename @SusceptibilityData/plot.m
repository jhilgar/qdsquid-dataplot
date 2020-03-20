function plot(obj, varargin)
    p = inputParser;
    argName = 'plot_type';
    defaultVal = 'm';
    p.addOptional(argName, defaultVal, @ischar);
    p.addParameter('Spacing', 1);
    p.parse(varargin{:});

    data_group = obj.Parsed.DataBlock;
    xdata = obj.Parsed.Temperature;
    labels{1} = 'Temperature (K)';
    switch p.Results.plot_type
        case 'm'
            ydata = obj.Parsed.Moment;
            labels{2} = 'Moment (emu)';
        case 'mmass'
            ydata = obj.Parsed.MomentMass;
            labels{2} = 'Moment (emu/g)';
        case 'xt'
            ydata = obj.Parsed.ChiT;
            labels{2} = '\chiT (emu mol^{-1} K)';
        case 'invx'
            ydata = 1 ./ obj.Parsed.Chi;
            labels{2} = '1/\chi (mol/emu)';
        otherwise
            disp('Unrecognized plot type, supported: m (emu), mmass (emu/gram), xt (emu K/mol), invx (mol/emu)');
            return;
    end

    PlotHelper.plotDataset(xdata, ydata, data_group, 'scatter', p.Results.Spacing, 'o');
    xlabel(labels{1}); ylabel(labels{2});
end