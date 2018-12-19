# qdsquid-dataplot
A collection of MATLAB functions that parse and plot data from a Quantum Design MPMS 3 SQUID magnetometer.

## Setup
The folder containing these scripts should be added to your MATLAB path. This can be done by clicking the **Set Path** button under the **Home** tab.

## Usage
Datafiles (.dat) are parsed by classes whose only constructor arguments are filenames. Currently there are four data class types: `AcData`, `DcData`, `SusData`, and `MagData`. The corresponding object properties contain raw, parsed, and fitted data and the object methods perform routine operations on these data (plotting, exporting, etc.). Two additional classes are `Relaxation`, which is responsible for fitting relaxation processes, and `PlotHelper` which provides some static methods for plotting convenience. Type `help SQUIDData` at the MATLAB command prompt for detailed usage information.

## Input files
Datafile headers are parsed and used to perform conversions and corrections to the data. These fields can be set in the 'Sample Properties' window of MultiVu or manually using a text editor. They should be set **before** using this code.

* **Material**: Should be a Matlab-safe variable name. (Good: `Fe_OAc2`) (Bad: `180420-!-BestSMM`) 
See [this](https://www.mathworks.com/help/matlab/matlab_prog/variable-names.html) for more details.
* **Comment**: Not used
* **Sample Holder**: Not used
* **Mass**: Sample mass in mg
* **Volume**: Mass of eicosane (put 0 if no eicosane was used)
* **Molecular Weight**: Sample molecular weight in g mol<sup>-1</sup>
* **Size**: Sample molar diamagnetism (put 0 if uncalculated)
* **Shape**: Not used

## Example
```
>> susErCOT = SusData('180607_KErCOT2_MvsT.dat')

susErCOT = 

  SusData with properties:

      Fields: 999.6509
    Filename: '180607_KErCOT2_MvsT.dat'
      Header: [1×9 table]
         Raw: [342×89 table]
      Parsed: [342×7 table]
        
>> figure();
>> susErCOT.plotChiT();
```