# qdsquid-dataplot
A collection of MATLAB functions that parse and fit data from a Quantum Design MPMS 3 and MPMS XL SQUID magnetometers.

## Setup
The folder containing these scripts should be added to your MATLAB path. This can be done by clicking the **Set Path** button under the **Home** tab. See [this](https://www.mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html) for more details.

## Usage
Datafiles (.dat) are parsed by classes whose constructor arguments are filenames or lists of filenames. Constructors called without arguments parse all .dat files in the current directory. Classes that typical users will instantiate are: `ACData`, `MagnetizationData`, `SusceptibilityData`, and `WaveformData`. The corresponding object properties contain raw, parsed, and potentially fitted data and the object methods perform routine operations on these data (currently: fitting, exporting). Each class instance of `ACData` and `WaveformData` corresponds to one model fit of the supplied dataset(s). SQUID versions and measurement modes are automatically detected and currently supported types are:
(MPMS 3) AC, DC, and VSM
(MPMS XL) AC, DC, and RSO.

## Input files
Datafile headers are parsed and used to perform conversions and corrections to the data. These fields can be set in the 'Sample Properties' window of MultiVu or manually using a text editor. They should be set **before** using this code. Their convention differs depending on the type of magnetometer used:

**For all magnetometers**
* **Mass**: Sample mass in mg

**For MPMS 3 data**
* **Molecular Weight**: Sample molecular weight in g mol<sup>-1</sup>
* **Volume**: Mass of eicosane in mg
* **Size**: Sample molar diamagnetism

**For MPMS XL data**
* **Area**: Mass of eicosane in mg
* **Length**: Sample molecular weight in g mol<sup>-1</sup>
* **Shape**: Sample molar diamagnetism

## &tau; model classes
#### `ACData`
Parses and fits standard AC susceptibility data to a generalized Debye model.

#### `WaveformData`
Performs the Fourier transform on DC, RSO, or VSM moment data and fits the resulting susceptibilities to a generalized Debye model. Details about this method can be found in: https://arxiv.org/abs/1907.05962

## Export format
Data tables are exported to .xlsx files using `objectName.writeData()`. Sheet 1 contains `objectName.Parsed`. &tau; model classe also contain sheets 2, 3, and 4 which correspond to `objectName.Fits`, `objectName.Errors`, and `objectName.Model`.

## Caveat emptor
The current release of this code package does little in the way of error handling (e.g. class/data mismatch). Therefore, the occassional file parsing error or user oversight will most likely be met with a potentially unhelpful MATLAB error message.

## Example usage
Example files can be found in the _examples_ directory
### (1) AC susceptibility
**_Data import:_**
```
>> Er_COT_I_THF2_AC = ACData('171124 - Er(COT)I(THF)2 - ACvsF.dat')
171124 - Er(COT)I(THF)2 - ACvsF.dat missing header information (replacing with default values):
    'EicosaneMass'

Fitting DebyeData with GeneralizedDebye fit type.

Er_COT_I_THF2_AC =

  ACData with properties:

      FitType: 'GeneralizedDebye'
         Fits: [18×5 table]
       Errors: [18×9 table]
        Model: [1800×4 table]
    DataFiles: [1×1 SQUIDDataFile]
       Parsed: [540×8 table]
```
**_View subset of fits:_**
```
>> Er_COT_I_THF2_AC.Fits(1:5, :)

ans =

 5×5 table

   TemperatureRounded      Xt        Xs        alpha        tau
   __________________    ______    _______    _______    _________

            5            2.1409    0.14513    0.14138    0.0023311
          5.5            1.9509    0.13367    0.14192     0.002325
            6            1.7919    0.12439    0.14122    0.0023092
          6.5            1.6565    0.11631    0.13975    0.0022813
            7            1.5398    0.10945    0.13697    0.0022367
```
**_Export data:_**
```
>> Er_COT_I_THF2_AC.writeData
Wrote data to Er_COT_I_THF2_AC.xlsx
```
### (2) Long timescale waveform
**_Data import:_**
```
>> Er_hdcCOT2_waveform = WaveformData()
SQUIDData constructor called with no arguments, reading all .dat files in current directory.
Fitting DebyeData with GeneralizedDebye fit type.

Er_hdcCOT2_waveform =

  WaveformData with properties:

      Spectra: [125151×4 table]
      FitType: 'GeneralizedDebye'
         Fits: [5×5 table]
       Errors: [5×9 table]
        Model: [500×4 table]
    DataFiles: [5×1 SQUIDDataFile]
       Parsed: [45×5 table]
```
**_View subset of calculated impedance data:_**
```
>> Er_hdcCOT2_waveform.Parsed(1:5, :)

ans =

  5×5 table

    TemperatureRounded    Frequency     ChiIn     ChiOut       phi
    __________________    __________    ______    _______    ________

            2             0.00013011    5.5083    0.26636    0.048317
            2             0.00026003    5.4157    0.45522    0.083857
            2             0.00051861    5.1768    0.83523     0.15996
            2              0.0010334    4.6218     1.3189     0.27797
            2              0.0020498    3.7456      1.612      0.4064
```
