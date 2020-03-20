function plot(obj, plot_type, varargin)
    p = inputParser;
    p.addParameter('Spacing', 1);
    p.parse(varargin{:});

    model_group = obj.Model.TemperatureRounded;
    data_group = obj.Parsed.TemperatureRounded;
    switch plot_type
        case 'in'
            xdata = obj.Parsed.Frequency;
            ydata = obj.Parsed.ChiIn;
            xmodel = obj.Model.Frequency;
            ymodel = obj.Model.ChiIn;
            xscale = 'log';
            labels = {'Frequency (Hz)', '\chi\prime (emu mol^{-1})'};
        case 'out'
            xdata = obj.Parsed.Frequency;
            ydata = obj.Parsed.ChiOut;
            xmodel = obj.Model.Frequency;
            ymodel = obj.Model.ChiOut;
            xscale = 'log';
            labels = {'Frequency (Hz)', '\chi\prime\prime (emu mol^{-1})'};
        case 'cole'
            xdata = obj.Parsed.ChiIn;
            ydata = obj.Parsed.ChiOut;
            xmodel = obj.Model.ChiIn;
            ymodel = obj.Model.ChiOut;
            xscale = 'linear';
            labels = {'\chi\prime (emu mol^{-1})', '\chi\prime\prime (emu mol^{-1})'};
        otherwise
            plot@TauData(obj, plot_type, varargin{:});
            return;
    end

    switch class(obj)
        case 'ACData'
            marker = 'o';
        case 'WaveformData'
            marker = 'square';
        otherwise
            marker = '*';
    end

    PlotHelper.plotDataset(xdata, ydata, data_group, 'scatter', p.Results.Spacing, marker, varargin{:});
    PlotHelper.plotDataset(xmodel, ymodel, model_group, 'line', p.Results.Spacing, marker, varargin{:});
    
    set(gca, 'XScale', xscale);
    xlabel(labels{1}); ylabel(labels{2});
    switch plot_type
        case 'in'
            xticks(logspace(-5, 3, 9));
        case 'out'
            xticks(logspace(-5, 3, 9));
    end
end