# qdsquid-dataplot
A collection of Matlab functions that parse and plot data from a Quantum Design MPMS 3 SQUID magnetometer.

## Setup
The folder containing these scripts should be added to your Matlab path. This can be done by clicking the **Set Path** button under the **Home** tab.

## Usage
The root function of this library is parseFile, 
```
function allOut = parseFile(filename)
```
The output `allOut` is a structure array containing header, data, rounded temperature, and colormap information. All plot functions accept this array as an input. `parseFile` performs some basic calculations on the data and thus requires a properly formatted file header to function:

* **Material**: Should be a Matlab-safe variable name. (Good: `Fe_OAc2`) (Bad: `180420-!-BestSMM`) 
See [this](https://www.mathworks.com/help/matlab/matlab_prog/variable-names.html) for more details.
* **Comment**: Not used
* **Sample Holder**: Not used
* **Mass**: Sample mass in mg
* **Volume**: Mass of eicosane (put 0 if no eicosane was used)
* **Molecular Weight**: Sample molecular weight in g mol<sup>-1</sup>
* **Size**: Sample molar diamagnetism (put 0 if uncalculated)
* **Shape**: Not used

From a parsed file, susceptibility (χT (emu K mol<sup>-1</sup>) vs. T) and magnetization (M (μ<sub>B</sub>) vs. H) plots are easily generated with,

```
plotSusceptibility(parseFile('DATAFILE.DAT'))
```
and
```
plotMagnetization(parseFile('DATAFILE.DAT'))
```
