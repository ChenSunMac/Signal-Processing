# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 

## [Unreleased]

## [0.9] - 2017-06-22
### Added
 -  In Configuration.m added option RESONANCE_PSD_SEARCH_FOR_PEAKS. When set to TRUE
    the peak search algorithm will look for peaks in the resonance PSD otherwise the 
    algotihm will look for troughs.
 -  In Process.m added functionality to store process results to a folder. One result
    file is generated for each file of scan data. 
 -  In Process.m added functionality to handle the configuration option RESONANCE_PSD_SEARCH_FOR_PEAKS.

### Changed
 -  Changed calliper algorithm to use max value from correlation instead of
    absolute value when searching for start of signal
 -  In ViewBluenoseData.m added transducer layout from May 17th. 
 -  readDataFileVersion_1_0.m bumped version to <bluenose V1.1>


## [0.8] - 2017-02-10
### Added
-	Added doxygen comments to ThicknessAlgorithm
-	Added an enumeration class for Validation Parameter types
-	Added function to ViewBluenoseData for extracting address to an area in a image
-	Added function to Process for processing an area given by the address struct
-	Added functionality for batch processing with different configuration setting for each processing. 
-	Added functionality for reprocessing a specified area. User can select an area of an image figure by drawing a rectangle. 
-	Added class SignalGenerator for creating signal pulses.
-	Added script filterDesign.m for creating filter for shaping emitted pulse
-   Added CHANGELOG.md

### Changed
-	Cleaned up HarmonicSet class: Added doxygen comments
-	Validation parameter: Deviation is calculated based on deviation from average frequency, before this was calculated based on the theoretical F0 given by the two first frequencies in the set. 
-	Changed function calculateAverageFreqDiff(), so when calculating the average frequency difference we only use the peaks that are present in the set, and not skipped frequencies. 
-	Changed HarmonicSet class to use a struct for the frequency when creating an instance of the class. The struct contains the fields ( freq, peakValue, index) 
-	Cleaned up Noise class: Added ref to Configuration class
-	Cleaned up ProcessingResult class
-	Changed ProcessingResult data format type of many of the class properties. 
-	Changed TransducerMeasurement data format type of many of the class properties.
-	Made most classes copyable by subclassing ‘matlab.mixin.Copyable’
-   Rename version.txt to VERSION.md
-   Changed Configuration class to contain REQUIRED_NO_HARMONICS and MAX_LENGTH_WELCH
