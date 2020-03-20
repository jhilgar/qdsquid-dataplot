classdef SQUIDDataFile < handle & matlab.mixin.CustomDisplay
    properties
        Filename        = []; % (string) filename
        MeasurementType = []; % (string) AC, DC, VSM, and RSO are recognized
        SQUIDType       = []; % (string) MPMS3 and MPMSXL are recognized
        Header          = []; % (table) header information
        Raw             = []; % (table) raw data
    end
    
    properties (Hidden = true, Constant)
        ACFieldsRaw = {'Time', 'Temperature', 'Field', 'Frequency', 'ChiIn', 'ChiInErr', 'ChiOut', 'ChiOutErr'};
        MomentFieldsRaw = {'Time', 'Temperature', 'Field', 'Moment', 'MomentErr'};
        EicosaneMW = 282.55;
        EicosaneXdm = -0.00024306;
    end

    properties (Access = protected)
        MeasurementTypeIdx = [];
        SQUIDTypeIdx = [];
    end
    
    properties (Access = protected, Constant)
        MeasurementTypes = {'AC', 'DC', 'RSO', 'VSM'};
        SQUIDTypes = {'MPMS3', 'MPMSXL'};
        
        HeaderDefaultValues = {'no name given', 'no description given', '10', '0', '500', '0'};
        HeaderFieldsMPMS3 = {'SAMPLE_MATERIAL', 'SAMPLE_COMMENT', 'SAMPLE_MASS', 'SAMPLE_VOLUME', 'SAMPLE_MOLECULAR_WEIGHT', 'SAMPLE_SIZE'};
        HeaderFieldsMPMSXL = {'NAME', 'COMMENT', 'WEIGHT', 'AREA', 'LENGTH', 'SHAPE'};
        HeaderFieldsRaw = {'Name', 'Description', 'Mass', 'EicosaneMass', 'MolecularWeight', 'Xdm'};
        HeaderFields = {SQUIDDataFile.HeaderFieldsMPMS3, SQUIDDataFile.HeaderFieldsMPMSXL, SQUIDDataFile.HeaderFieldsRaw};
        
        ACFieldsMPMS3 = {'TimeStamp_sec_', 'Temperature_K_', 'MagneticField_Oe_', 'ACFrequency_Hz_', 'ACX__emu_Oe_', 'ACX_StdErr__emu_Oe_', 'ACX___emu_Oe_', 'ACX__StdErr__emu_Oe_'};
        ACFieldsMPMSXL = {'Time', 'Temperature_K_', 'Field_Oe_', 'WaveFrequency_Hz_', 'm__emu_', 'm_ScanStdDev', 'm__emu__1', 'm_ScanStdDev_1'};
        ACFields = {SQUIDDataFile.ACFieldsMPMS3, SQUIDDataFile.ACFieldsMPMSXL, SQUIDDataFile.ACFieldsRaw};

        DCFieldsMPMS3 = {'TimeStamp_sec_', 'Temperature_K_', 'MagneticField_Oe_', 'DCMomentFreeCtr_emu_', 'DCMomentErrFreeCtr_emu_'};
        DCFieldsMPMSXL = {'Time', 'Temperature_K_', 'Field_Oe_', 'LongMoment_emu_', 'LongScanStdDev'};
        DCFields = {SQUIDDataFile.DCFieldsMPMS3, SQUIDDataFile.DCFieldsMPMSXL, SQUIDDataFile.MomentFieldsRaw};
        
        RSOFieldsMPMS3 = {};
        RSOFieldsMPMSXL = {'Time', 'Temperature_K_', 'Field_Oe_', 'LongMoment_emu_', 'LongScanStdDev'};
        RSOFields = {SQUIDDataFile.RSOFieldsMPMS3, SQUIDDataFile.RSOFieldsMPMSXL, SQUIDDataFile.MomentFieldsRaw};
        
        VSMFieldsMPMS3 = {'TimeStamp_sec_', 'Temperature_K_', 'MagneticField_Oe_', 'Moment_emu_', 'M_Std_Err__emu_'};
        VSMFieldsMPMSXL = {};
        VSMFields = {SQUIDDataFile.VSMFieldsMPMS3, SQUIDDataFile.VSMFieldsMPMSXL, SQUIDDataFile.MomentFieldsRaw};
        
        LookupTable = {SQUIDDataFile.ACFields, SQUIDDataFile.DCFields, SQUIDDataFile.RSOFields, SQUIDDataFile.VSMFields};
    end
    
    methods
        function obj = SQUIDDataFile(filename)
            obj.Filename = filename;
            fileID = fopen(obj.Filename, 'r');
            obj.parseFile(textscan(fileID, '%s', 50, 'Delimiter', '\n'));
            fclose(fileID);
        end 

        function writeData(obj, fileName, sheetNumber)
            writetable(obj.Raw, fileName, 'Sheet', ['Datafile ' num2str(sheetNumber)]);
        end
    end
    
    methods (Access = private)
        idx = determineMeasurementType(obj, contents);
        idx = determineSQUIDType(obj, contents);

        parseFile(obj, contents);
        parseHeader(obj, contents, dataLine);
    end
end