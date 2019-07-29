function model = generalizedDebyeModel(b, x)
    % b(1) => Xt
    % b(2) => Xs
    % b(3) => alpha
    % b(4) => tau
    x = 2 * pi .* x;
    model(:,1) = b(2) + (b(1) - b(2)) * ((1 + power(x * b(4), 1 - b(3)) * sin(pi * b(3) / 2)) ./ (1 + 2 * power(x * b(4), 1 - b(3)) * sin(pi * b(3) / 2) + power(x * b(4), 2 * (1 - b(3)))));
    model(:,2) = (b(1) - b(2)) * power(x * b(4), 1 - b(3)) * cos(pi * b(3) / 2) ./ ((1 + 2 * power(x * b(4), 1 - b(3)) * sin(pi * b(3) / 2) + power(x * b(4), (2 * (1 - b(3))))));
end