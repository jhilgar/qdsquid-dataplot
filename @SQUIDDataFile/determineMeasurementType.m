function idx = determineMeasurementType(obj, contents)
    switch obj.SQUIDType
        case obj.SQUIDTypes{1}
            if ~isnan(obj.Raw.ACMoment_emu_)
                idx = 1;
            elseif ~isnan(obj.Raw.DCMomentFreeCtr_emu_)
                idx = 2;
            elseif ~isnan(obj.Raw.Moment_emu_)
                idx = 4;
            else
                idx = 0;
            end
        case obj.SQUIDTypes{2}
            if contains(contents{1}{2}, 'AC')
                idx = 1;
            elseif contains(contents{1}{2}, 'DC')
                idx = 2;
            elseif contains(contents{1}{2}, 'RSO')
                idx = 3;
            elseif contains(contents{1}{2}, 'VSM')
                idx = 4;
            end
        otherwise
            idx = 0;
    end
end