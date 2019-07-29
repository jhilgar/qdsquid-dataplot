function parseFile(obj, contents)
    dataLine = [];

    warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames');

    for a = 1:length(contents{1})
        if strcmp('[Data]', contents{1}{a})
            dataLine = a;
            break;
        end
    end

    obj.Raw = readtable(obj.Filename, 'HeaderLines', dataLine, 'CommentStyle', {'(', ')'});
    obj.SQUIDTypeIdx = obj.determineSQUIDType(contents);
    obj.SQUIDType = obj.SQUIDTypes{obj.SQUIDTypeIdx};
    obj.MeasurementTypeIdx = obj.determineMeasurementType(contents);
    obj.MeasurementType = obj.MeasurementTypes{obj.MeasurementTypeIdx};

    obj.Raw.Properties.VariableNames(obj.LookupTable{obj.MeasurementTypeIdx}{obj.SQUIDTypeIdx}) = obj.LookupTable{obj.MeasurementTypeIdx}{end};
    obj.parseHeader(contents, dataLine);
    obj.Raw = rmmissing(obj.Raw, 2);
end