function plotArrhenius(allIn)

    if length(allIn) ~= 6
        error('This function should only be passed fitted data. Use fitACFreq.')
    else
        setDefaults();
        hold on;

        scatter(1./allIn{3}, log(allIn{6}(:,4,1)), 55, allIn{4}, 'filled');
        plot(1./allIn{3}, polyval(allIn{5}, 1./allIn{3}),'Color','black');
        
        xlim([1/(allIn{3}(end)+1) 1/(allIn{3}(1)-1)])
        xa = [1/(allIn{3}(end)) 1/(allIn{3}(1))]
        tik = flip(1/xa(2):2:1/xa(1));
        xticks(1./tik);
        xticklabels(num2cell(tik));
        text(0.7 ,0.2, {sprintf('\\itU_{eff}\\rm\\bf = %.1f cm^{-1}',allIn{5}(1) * 0.695),sprintf('\\it\\tau_{0}\\rm\\bf = %.2d s',exp(allIn{5}(2)))}, 'Units','Normalized', 'FontWeight', 'Bold', 'FontSize', 12, 'HorizontalAlignment', 'center');
        xlabel('Temperature (K)');
        
        ylim([log(1e-4) log(1e-1)]);
        yticks([log(1e-4) log(1e-3) log(1e-2) log(1e-1) log(1) log(10)]);
        yticklabels({'10^{-4}', '10^{-3}', '10^{-2}', '10^{-1}', '1', '10'});
        ylabel('\tau (s)');
    end
    
end