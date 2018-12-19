classdef PlotHelper
	methods(Static)
        function color = dataColor(temperature)
            color = hsv2rgb([1-tanh(temperature/20) ones(length(temperature), 1)*0.8 ones(length(temperature), 1)*1]);
        end
       
        function setDefaults()
            set(groot,'defaultLineLineWidth',1.5);
            set(groot,'defaultAxesLineWidth',1.5);
            set(groot,'defaultLineMarkerSize',6);
            set(groot,'defaultScatterLineWidth',1.5);
            set(groot,'defaultAxesFontWeight','bold');
            set(groot,'defaultAxesFontSize',11.5);
            set(groot,'defaultAxesNextPlot','add');
            set(groot,'defaultScatterSizeData',15);
            set(groot,'defaultAxesBox','on');
            set(groot,'defaultAxesTickLength', [0.012 0.007]);
            set(groot,'defaultFigurePaperPosition', [0 0 8 8]);
            set(groot,'defaultScatterSizeData',15);
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