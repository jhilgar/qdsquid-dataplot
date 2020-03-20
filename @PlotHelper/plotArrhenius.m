function plotArrhenius(obj, varargin)
    xdata = 1 ./ obj.Fits.TemperatureRounded;
    if isempty(varargin)
        ydata = log(obj.Fits.tau);
    else
        ydata = log(obj.Fits{:, ['tau' num2str(varargin{1})]});
    end
    
    switch class(obj)
        case 'ACData'
            marker = 'o';
        case 'WaveformData'
            marker = 'square';
        case 'ExponentialData'
            switch obj.FitType
                case 'StretchedExponential'
                    marker = '^';
                case 'BiExponential'
                    marker = 'v';
                otherwise
                    marker = '*';
            end
        otherwise
            marker = '*';
    end

    PlotHelper.plotDataset(xdata, ydata, obj.Fits.TemperatureRounded, 'scatter', 1, marker);
    if isprop(obj, 'Uncertainties') && ~isempty(obj.Uncertainties)
        errorbar(xdata, ydata, log(obj.Fits.tau) - log(obj.Uncertainties.tau_sigmaNeg), log(obj.Uncertainties.tau_sigmaPos) - log(obj.Fits.tau), 'o', 'Color', 'black', 'MarkerSize', 0.01);
    end
    xlabel('1 / T (K^{-1})'); ylabel('log(\tau)');
end