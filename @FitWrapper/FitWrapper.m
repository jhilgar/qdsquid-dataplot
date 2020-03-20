classdef FitWrapper
    methods (Static)
        function [fit, resid, J] = fitData(fitMethod, objective, x0, lb, ub, varargin)
            if nargin == 6;
                opts = 'asdf';
            else
                opts = optimoptions(fitMethod, varargin{:})
            end

            
        end
    end
end