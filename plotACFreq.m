function plotACFreq(allIn)

    figure;
    
    subplot(2, 2, 1);
    plotACIn(allIn);
    subplot(2, 2, 2);
    plotACOut(allIn);
    subplot(2, 2, 3);
    plotColeCole(allIn);
    subplot(2, 2, 4);
    plotArrhenius(allIn);
    
    %{
    for a = 1:size(allIn,1)
        [b c] = makeFigures();
        plotDataSet(allIn(a,:), c)
        %dlmwrite(strcat(allIn{1}.Filename{1},'_times.txt'),[allIn{3} allIn{6}(:,4,1)],',');
    end
    %}
end

function plotDataSet(allIn, axes)
   
    for a = 1:length(allIn{3})
        rows = allIn{2}.TemperatureRounded == allIn{3}(a);

                scatter(axes(1),allIn{2}.AcFreq(rows), allIn{2}.ChiPrime(rows), 55,[allIn{2}.Red(rows) allIn{2}.Green(rows) allIn{2}.Blue(rows)], 'filled');
                plot(axes(1),allIn{2}.AcFreq(rows),modelin(allIn{6}(a,1:4), allIn{2}.AcFreqRad(rows)),'Color',[0 0 0]);
                
        h(a) =  scatter(axes(2),allIn{2}.AcFreq(rows), allIn{2}.ChiDoublePrime(rows),55, [allIn{2}.Red(rows) allIn{2}.Green(rows) allIn{2}.Blue(rows)],'filled');
                plot(axes(2),allIn{2}.AcFreq(rows),modelout(allIn{6}(a,1:4),allIn{2}.AcFreqRad(rows)),'Color',[0 0 0]);
                
                scatter(axes(3), allIn{2}.ChiPrime(rows), allIn{2}.ChiDoublePrime(rows),55, [allIn{2}.Red(rows) allIn{2}.Green(rows) allIn{2}.Blue(rows)],'filled');
                plot(axes(3),modelin(allIn{6}(a,1:4), allIn{2}.AcFreqRad(rows)),modelout(allIn{6}(a,1:4),allIn{2}.AcFreqRad(rows)),'Color',[0 0 0]);
                
                %uistack(plotin,'bottom');
                %uistack(plotout, 'bottom');
                %uistack(plotcole, 'bottom');
    end
    
    scatter(axes(4), 1./allIn{3}, log(allIn{6}(:,4,1)), 55, allIn{4}, 'filled');
    plot(axes(4), 1./allIn{3}, polyval(allIn{5}, 1./allIn{3}),'Color','black');
    xa = xlim;
    ya = ylim;
    tik = flip(1/xa(2):2:1/xa(1));
    xticks(1./tik);
    xticklabels(num2cell(tik));
    text(0.7 ,0.2, {sprintf('\\itU_{eff}\\rm\\bf = %.1f cm^{-1}',allIn{5}(1) * 0.695),sprintf('\\it\\tau_{0}\\rm\\bf = %.2d s',exp(allIn{5}(2)))}, 'Units','Normalized', 'FontWeight', 'Bold', 'FontSize', 12, 'HorizontalAlignment', 'center');
    %errorbar(axes(4), 1./allIn{3}, log(allIn{6}(:,4,1)), log(allIn{6}(:,4,2))-log(log(allIn{6}(:,4,1))),  log(log(allIn{6}(:,4,1)))-log(log(allIn{6}(:,4,3))),'LineStyle','none');
end

function [ffigures, faxis] = makeFigures()
    faxis = zeros(4,1);
    ffigures = zeros(4,1);
    
    for a = 1:4
        ffigures(a) = figure;
        faxis(a) = gca;
        set(faxis(a),'Box','on','Nextplot','add');
        axis square;
        axis tight;
        switch a
            case 1
                xticks([1 10 100 1000]);
                xticklabels({'1', '10', '100', '1000'});
                xlabel('Frequency (Hz)');
                xlim([0.8 1200]);
                ylim([0 3]);
                ylabel('\chi\prime (emu mol^{-1})');
                %title('In-phase Susceptibility');
                set(faxis(a),'XScale','log');
            case 2
                xticks([1 10 100 1000]);
                xticklabels({'1', '10', '100', '1000'});
                xlabel('Frequency (Hz)');
                xlim([0.8 1200]);
                ylim([0 1.5]);
                ylabel('\chi\prime\prime (emu mol^{-1})');
                %title('Out-of-phase Susceptibility');
                set(faxis(a),'XScale','log');
            case 3
                xlabel('\chi\prime (emu mol^{-1})');
                xlim([0 2.5]);
                ylim([-.1 2.5]);
                ylabel('\chi\prime\prime (emu mol^{-1})');
                %title('Cole-Cole Plot');
            case 4
                ylim([log(1e-4) log(1e-1)]);
                yticks([log(1e-4) log(1e-3) log(1e-2) log(1e-1) log(1) log(10)]);
                yticklabels({'10^{-4}', '10^{-3}', '10^{-2}', '10^{-1}', '1', '10'});
                xlabel('Temperature (K)');
                ylabel('\tau (s)');
                %title('Arrhenius Plot');
        end
    end
end
