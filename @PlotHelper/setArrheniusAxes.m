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