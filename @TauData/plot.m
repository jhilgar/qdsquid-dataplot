function plot(obj, plot_type, varargin)
    p = inputParser;
    p.addParameter('Spacing', 1);
    p.parse(varargin{:});

    switch plot_type
        case 'arrhenius'
            xdata = 1./obj.Fits.Temperature;
            columns = obj.Fits(:, contains(obj.Fits.Properties.VariableNames, 'tau'));
            ydata = log(reshape(table2array(columns), [height(obj.Fits)*width(columns), 1]));
            xdata = repmat(xdata, width(columns), 1);
            xscale = 'linear';
            xmodel = [];
            ymodel = [];
            model_group = [];
            data_group = repmat(obj.Fits.Temperature, 1, width(columns));
            labels = {'1/T', 'ln(\tau)'};
        otherwise
            disp('Unrecognized plot type.');
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
    set(gca, 'XScale', xscale);
    xlabel(labels{1}); ylabel(labels{2});
end