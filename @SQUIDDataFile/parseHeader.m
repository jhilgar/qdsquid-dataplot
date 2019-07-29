function parseHeader(obj, contents, dataLine)
    header = [];
    for a = 1:dataLine
        if strncmp(contents{1}{a}, 'INFO', 4) && ~contains(contents{1}{a}, 'APPNAME') && ~contains(contents{1}{a}, 'SEQUENCE FILE') && ~contains(contents{1}{a}, 'BACKGROUND DATA FILE:')
            header = [header; regexp(contents{1}{a}, ',', 'split')];
        end
    end
    
    switch obj.SQUIDTypeIdx
        case 1
            header = cell2table(header(:, 2)', 'VariableNames', header(:, 3)');
        case 2
            header = cell2table(strtrim(header(:, 3)'), 'VariableNames', header(:, 2)'); 
    end

    obj.Header = cell2table(header{1, obj.HeaderFields{obj.SQUIDTypeIdx}}, 'VariableNames', obj.HeaderFields{end});

    missingFields = ismissing(obj.Header);
    zeroFields = str2double(obj.Header{1, :}) == 0;
    badFields = missingFields | zeroFields;
    badFields = badFields & logical([1 1 1 0 1 0]);

    if any(badFields)
        disp([obj.Filename ' missing header information (replacing with default values):'] );
        disp(obj.HeaderFields{end}(badFields));
        obj.Header{:, badFields} = obj.HeaderDefaultValues(badFields);
    end
    
    obj.Header.Mass = str2double(obj.Header.Mass); obj.Header.EicosaneMass = str2double(obj.Header.EicosaneMass);
    obj.Header.MolecularWeight = str2double(obj.Header.MolecularWeight); obj.Header.Xdm = str2double(obj.Header.Xdm);
    
    obj.Header.Moles = obj.Header.Mass / 1000 / obj.Header.MolecularWeight;
    obj.Header.EicosaneMoles = obj.Header.EicosaneMass / 1000 / obj.EicosaneMW;
end