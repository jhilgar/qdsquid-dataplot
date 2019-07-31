classdef PlotHelper
    methods (Static)
        function plotDataset(x, y, group, varargin)
            PlotHelper.setDefaults();
            groups = unique(group);

            for a = 1:length(groups)
                rows = group == groups(a);
                plot(x(rows), y(rows), 'Color', PlotHelper.colorSelector(groups(a), a));
            end
        end

        function scatterDataset(x, y, group, varargin)
            PlotHelper.setDefaults();
            groups = unique(group);

            for a = 1:length(groups)
                rows = group == groups(a);
                scatter(x(rows), y(rows), [], PlotHelper.colorSelector(groups(a), a), 'filled');
            end
        end

        function depthScatterDataset(x, y, group, varargin)
            PlotHelper.setDefaults();
            groups = unique(group);

            for a = 1:length(groups)
                rows = group == groups(a);
                plot3(x(rows), y(rows), group(rows), '-o');
            end
        end

        function color = colorSelector(temperature, a)
            color = hsv2rgb([1-tanh(temperature/30)' double(~mod(a + 3, 3)) ones(length(temperature), 1)*0.9]);
            
        end

        function setDefaults()
            set(groot,'defaultAxesBox', 'on');
            set(groot,'defaultLineLineWidth', 1.5);
            set(groot,'defaultAxesLineWidth', 1.5);
            
            hold on;
        end
    end
end