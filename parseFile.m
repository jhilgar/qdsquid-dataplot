function allOut = parseFile(filename)

    fileID = fopen(filename, 'r');
    contents = textscan(fileID, '%s', 50, 'Delimiter', '\n');
    fclose(fileID);
    
    for a = 1:length(contents{1})
        if strcmp('[Header]', contents{1}{a})
            headerLine = a;
        elseif strcmp('[Data]', contents{1}{a})
            dataLine = a;
            break;
        end
    end
 
    header      = parseHeader(contents, headerLine, dataLine - 1);
    headerOut   = cell2table([ ...
        filename header(2,2) header(3,2) str2double(header(4,2)) str2double(header(5,2)) ...
        str2double(header(6,2)) str2double(header(4,2))/1000/str2double(header(6,2)) str2double(header(5,2))/1000/282.55 str2double(header(7,2)) -0.00024306 ...
        str2double(header(4,2))/1000/str2double(header(6,2))*(-0.00024306)], ...
        'VariableNames', {'Filename', 'Name', 'Description', 'Mass', 'EicosaneMass', 'MolecularWeight', 'Moles', 'EicosaneMoles', 'SampleXdm', 'EicosaneXdm', 'EicosaneXd'});
    
    data        = dlmread(filename,',',dataLine + 1, 0);
    tempRound   = round(data(:,3),1);
    sampleMudm  = data(:,4) * headerOut.SampleXdm;
    eicosaneMud = data(:,4) * headerOut.EicosaneXd;
    totalX      = headerOut.SampleXdm + headerOut.EicosaneXd;
    totalMud    = sampleMudm + eicosaneMud;
    dcMomentC   = data(:,61) - totalMud;
    chi         = data(:,61) ./ data(:,4) ./ headerOut.Moles - totalX;
    chiT        = chi .* data(:,3);
    uB          = (data(:,61) / headerOut.Moles) / 5585;
    color       = hsv2rgb([1-tanh(tempRound/30) ones(size(data(:,64),1),1)*0.8 ones(size(data(:,64),1),1)*1]);
    
    dataOut     = array2table([ ...
        data(:,2) data(:,3) tempRound data(:,4) data(:,5) data(:,6) data(:,22)/headerOut.Moles data(:,23) data(:,24)/headerOut.Moles data(:,25) ...
        data(:,27) data(:,27).*(2*pi) data(:,61) dcMomentC data(:,62) data(:,64) data(:,65) chi chiT uB color], ...
        'VariableNames', {'Time', 'Temperature', 'TemperatureRounded', 'Field', 'Moment', 'MomentErr', 'ChiPrime', 'ChiPrimeErr', 'ChiDoublePrime', 'ChiDoublePrimeErr', ...
        'AcFreq', 'AcFreqRad', 'DcMoment', 'DcMomentC', 'DcMomentErr', 'DcFit', 'DcCenter', 'Chi', 'ChiT', 'Magnetization', 'Red', 'Green', 'Blue'});
    
    dataOut = sortrows(dataOut, 'TemperatureRounded');
    toDelete = dataOut.AcFreq > 1000 | dataOut.ChiPrime < -1e-7 | dataOut.ChiDoublePrime < -1e-7 | dataOut.TemperatureRounded < 0 | dataOut.TemperatureRounded > 300;
    dataOut(toDelete,:) = [];
    temps = unique(dataOut.TemperatureRounded);
    colors = unique([dataOut.Red dataOut.Green dataOut.Blue],'rows', 'stable');
    allOut = {headerOut dataOut temps colors};
    assignin('base',allOut{1}.Name{1},allOut);
    
end

function header = parseHeader(contents, headerLine, dataLine)

    header = [];
    for i=headerLine:dataLine
        if strncmp(contents{1}{i}, 'INFO', 4) && not(length(strfind(contents{1}{i}, 'APPNAME')))
            header = [header; regexp(contents{1}{i}, ',', 'split')];
        end
    end
    if strcmp(header{2,2}, '')
        header{2,2} = 'None';
    end
    if strcmp(header{4,2}, '')
        header{4,2} = '100';
    end
    if strcmp(header{6,2}, '')
        header{6,2} = '1000';
    end
    
end