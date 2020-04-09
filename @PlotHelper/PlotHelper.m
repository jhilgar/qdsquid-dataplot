classdef PlotHelper
    properties (Hidden = true, Constant)
        colorAlpha = 0.5;
        hotTemp = 17;
        
        defaultAxesBox = 'on';
        defaultLineLineWidth = 1.5;
        defaultAxesLineWidth = 1.5;
        defaultAxesFontWeight = 'bold';
    end
    
    methods (Static)
        function plotDataset(x, y, group, plotType, colorSpacing, marker, varargin)
            if isempty(x) || isempty(y), return; end
            PlotHelper.setDefaults();
            p = inputParser;
            p.addParameter('Axes', gca);
            p.parse(varargin{:});
            groups = unique(group);
            toggle = double(~mod(colorSpacing+(0:length(groups)-1), colorSpacing));
            
            scatter_data = [];
            line_data = [];
            
            for a = 1:length(groups)
                rows = group == groups(a);
                handleVis = 'off';
                switch plotType
                    case 'scatter'
                        if toggle(a), handleVis = 'on'; end
                        newScatter = scatter(p.Results.Axes, x(rows), y(rows), [], PlotHelper.colorSelector(groups(a), toggle(a)), 'filled', marker, 'MarkerFaceAlpha', 1 - (PlotHelper.colorAlpha*(~toggle(a))), 'DisplayName', [num2str(groups(a)) ' K'], 'HandleVisibility', handleVis);
                        if ~toggle(a)
                            uistack(newScatter, 'bottom')
                        else
                            scatter_data = [scatter_data; newScatter];
                        end
                    case 'line'
                        newLine = plot(p.Results.Axes, x(rows), y(rows), 'Color', PlotHelper.colorSelector(groups(a), toggle(a)), 'HandleVisibility', handleVis);
                        newLine.Color(4) = 1 - (PlotHelper.colorAlpha*(~toggle(a)));
                        uistack(newLine, 'bottom');
                        line_data = [line_data; newLine];
                end
                legend(scatter_data); legend('off'); legend('show');
            end
        end

        function color = colorSelector(temperature, a)
            %color = hsv2rgb([1-tanh(temperature/30)' double(mod(a + 3, 3)) ones(length(temperature), 1)*0.9]);
            cmap = jet(100);
            temperature = floor(rescale(temperature, 1, 100, 'InputMin', 1.8, 'InputMax', PlotHelper.hotTemp));
            temperature = rgb2hsv(cmap(temperature, :));
            color = hsv2rgb([temperature(:, 1) double(mod(a + 3, 3))*temperature(:, 2) temperature(:, 3)*0.85]);
        end

        function setDefaults()
            set(groot,'defaultAxesBox', PlotHelper.defaultAxesBox);
            set(groot,'defaultLineLineWidth', PlotHelper.defaultLineLineWidth);
            set(groot,'defaultAxesLineWidth', PlotHelper.defaultAxesLineWidth);
            set(groot,'defaultAxesFontWeight', PlotHelper.defaultAxesFontWeight);
            set(groot,'defaultLegendBox', 'off');
            hold on;
            axis square;
        end
        
        function setLimits()
            currentXLim = xlim; xRange = currentXLim(2) - currentXLim(1);
            currentYLim = ylim; yRange = currentYLim(2) - currentYLim(1);
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
        
        function setArrheniusAxes()
            ax1 = gca;
            ax2 = axes('Position', get(ax1, 'Position'), 'Color', 'none');
            set(ax1, 'Box', 'off', 'XAxisLocation', 'top', 'YAxisLocation', 'right', 'Color', 'none');
            xlabel(ax1, '1/T (K^{-1})'); ylabel(ax1, 'ln(\tau)');
            set(ax2, 'Box', 'off');
            xlabel(ax2, 'T (K)'); ylabel(ax2, '\tau (s)');
            linkaxes([ax1, ax2]);
            linkprop([ax1, ax2], {'Position', 'PlotBoxAspectRatio'});
            uistack(gca, 'bottom');
            yticks(log(10.^(-5:4)));
            yticklabels({'10^{-5}', '10^{-4}', '10^{-3}', '10^{-2}', '10^{-1}', '1', '10', '10^{2}', '10^{3}', '10^{4}'});
            xlim(1 ./ [50 1.9]);
            xticks(1 ./ [16 8 4 2]);
            xticklabels(cellstr(num2str([16; 8; 4; 2])));
        end
    end
end