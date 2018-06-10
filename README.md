# qdsquid-dataplot
A collection of Matlab functions that parse and plot data from a Quantum Design MPMS 3 SQUID magnetometer.

## Setup
The folder containing these scripts should be added to your Matlab path. This can be done by clicking the **Set Path** button under the **Home** tab.

## Usage
Datafiles are parsed into objects whose constructor arguments are filenames. Currently there are three object types: `SusceptibilityData`, `MagnetizationData` and `AcData`. The object properties contain raw and parsed data and the object methods perform routine operations (plotting, exporting, etc.).

```
>> susErCOT = SusceptibilityData('180607_KErCOT2_MvsT.dat')
Warning: Variable names were modified to make them valid MATLAB identifiers. The original names are saved in the VariableDescriptions property. 

susErCOT = 

  SusceptibilityData with properties:

      Fields: 999.6509
    Filename: '180607_KErCOT2_MvsT.dat'
      Header: [1×9 table]
     RawData: [342×89 table]
        Data: [342×7 table]
        
>> susErCOT.plotSusceptibility
>> susErCOT.writePhi('KErCOT2');
```

The header of the datafile is parsed and used to perform conversions and corrections to the data. These fields can be set in the 'Sample Properties' window of MultiVu or manually using a text editor.

* **Material**: Should be a Matlab-safe variable name. (Good: `Fe_OAc2`) (Bad: `180420-!-BestSMM`) 
See [this](https://www.mathworks.com/help/matlab/matlab_prog/variable-names.html) for more details.
* **Comment**: Not used
* **Sample Holder**: Not used
* **Mass**: Sample mass in mg
* **Volume**: Mass of eicosane (put 0 if no eicosane was used)
* **Molecular Weight**: Sample molecular weight in g mol<sup>-1</sup>
* **Size**: Sample molar diamagnetism (put 0 if uncalculated)
* **Shape**: Not used
