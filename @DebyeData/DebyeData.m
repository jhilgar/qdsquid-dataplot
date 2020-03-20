classdef DebyeData < TauData
    properties (SetAccess = private)
        nCC = 0;
        nHN = 0;
    end

    methods
        fitTau(obj, varargin);
        plot(obj, type, varargin);

        function obj = DebyeData(varargin)
            obj = obj@TauData(varargin{:});
        end
    end
    
    methods (Static)
        function output = model(xdata, cc, hn, b)
            ycalc = 0;

            for a = 1:cc
                ycalc = ycalc + DebyeData.CC([b(((a - 1) * 3 + 1):((a - 1) * 3 + 3)), b(end)], xdata);
            end

            for a = 1:hn
                ycalc = ycalc + DebyeData.HN([b(((a - 1) * 4 + 1 + (cc * 3)):((a - 1) * 4 + 4 + (cc * 3))), b(end)], xdata);
            end

            output = b(end) + ycalc;
        end

        function output = CC(b, omega)
            omega = omega .* 2 * pi;
            output = (b(3) - b(4)) ./ (1 + power(1i .* omega .* b(1), 1 - b(2)));
        end

        function output = HN(b, omega)
            omega = omega .* 2 * pi;
            output = (b(4) - b(5)) ./ power(1 + power(1i .* omega .* b(1), b(2)), b(3));
        end
    end
end