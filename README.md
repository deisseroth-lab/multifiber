#fip multifiber
A minimal GUI for doing frame-projected independent-fiber photometry

See [paper in Nature Methods](http://www.nature.com/nmeth/journal/vaop/ncurrent/full/nmeth.3770.html) for details:

Kim, C., Yang, S., Pichamoorthy, N., Young, N., Kauvar, I., Jennings, J., Lerner, T., Berndt, A., Lee, S.Y., Ramakrishnan, C., Davidson, T., Inoue, M., Bito, H., & Deisseroth, K. (2016). Simultaneous fast measurement of circuit dynamics at multiple sites across the mammalian brain. Nature Methods.

## Background
Frame-projected independent-fiber photometry records the sum fluorescence from each of several optical fibers by imaging the fiber bundle onto a camera sensor and digitally cropping and summing the fluorescence from each fiber. Alternating excitation wavelengths for successive frames enables concurrent sampling of multiple spectral channels and/or optical stimulation.

## Hardware setup description
The software synchronizes various hardware (light sources, camera acquisition, behavoral apparatuses) by using digital and analog output voltage waveforms and reads image frames from the camera. The measure camera signal from each fiber position can be processed, visualized and accessed in real-time, and saved to hard disk for later analysis. In addition, simultaneous analog input recording is enabled.

Up to 4 analog output waveforms can be user-defined for controlling behavoral apparatuses and other hardware.

The software is based on MATLAB's GUI interface and Image and Data Acquisition toolboxes.

## Hardware requirements
Note: It may be possible to modify the software to work with other MATLAB-supported cameras and DAQ cards.
1. Hamamatsu Orca Flash4.0 V2
1. National Instruments DAQ Card (PCIe-6343-X and BNC-2090A/BNC-2110)
1. PC to support the above hardware -- see [Hamamatsu PC Recommendations](http://www.hamamatsu.com/sp/sys/en/documents/PCRecommendationforOrca-Flash4.0_20150212.pdf)

## Software requirements
1. MATLAB (tested with R2013b, R2014b, R2015a, R2015b)
1. MATLAB [Image Acquisition](http://www.mathworks.com/products/imaq/) toolbox and [adaptor for camera](http://www.mathworks.com/help/imaq/installing-the-support-packages-for-image-acquisition-toolbox-adaptors.html). The Image Acquisition toolbox may require the Image Processing toolbox.
1. MATLAB [Data Acquisition](http://www.mathworks.com/products/daq/) toolbox

## Installation and configuration
1. Ensure the camera and DAQ hardware are accessible using their provided software (e.g. [HCImage Live](http://hcimage.com/hcimage-overview/hcimage-live/)).
1. Ensure the MATLAB toolboxes and camera adaptor are installed (see above).
1. Run `fipgui.m`.
1. In the GUI, select the counter channels to correspond to the physical DAQ connections.

## Real-time data access
In the GUI, select a call-back function file, e.g. `sample_scripts/sample_callback.m`.
This function is expected to have signature `myfunction(data, channel)` where
`data` is a 1 x n_fibers matrix of the latest intensity values for each fiber
and `channel` is a string describing what `data` represents. `channel` may take
on values "signal", "reference", or "test". "test" is used when FIPGUI does
preliminary checks to make sure everything works before acquiring.

If you would like to maintain state between evaluations of your call-back,
FIGUI now accepts a Matlab class file to handle data in real time. This can be
useful if you would like to use state information, such as previous data
values, in your response to each incoming data value. It also allows you to
reference useful variables and objects, such as a separate analog channel or
file handle that you would like to use repeatedly when new data arrives.

Class files used as callbacks must have a zero-argument constructor and a
function `update(object, data, channel)` which is the function actually called
when data is available.

## User-defined analog output voltage waveforms
Run `sample_generate_ao_waveform.m` or `sample_generate_ao_waveform_stim.m` to produce an example waveform file, then in the GUI, select that waveform `.mat` file.

Implementation detail: the digital counter waveforms and analog output waveforms are in the same Session object, so the synchronization will be consistent across acquisition sessions. However, the precise synchronization may be different with different versions of MATLAB (e.g. R2013b to R2015b and possibly more). Use analog input recording to verify the accuracy of any synchronization, and adjust the analog output waveform accordingly (e.g. set `stim_start` in `sample_scripts/sample_generate_ao_waveform_stim.m`).

## Analog input recording
Ensure the desired physical connections are made to the DAQ analog input channels. Then, in the GUI, enable the checkbox for analog input recording. A `.csv` file will be saved along with the other acquisition data. Visualize the recorded data by using the GUI button or `plotLogFile.m`.

## A note about maximum acquisition rate
The maximum acquisition rate may depend on several factors:
1. The camera readout time. For the Orca's bidirectional center-outwards rolling shutter, the camera readout time is set by the minimum of the distance from the farthest row from the center to the center of the image sensor, and the distance between the two most-distant rows.
1. (Untested but likely) time it takes callback function to run
1. (Untested but likely) efficiency of live plotting

## Troubleshooting
1. The `tests/` directory contains tests for checking each hardware component separately.
1. If the GUI crashes during initialization, there may be a problen with the configurations that FIPGUI persists between sessions. Try running
`rmpref('FIPGUI')` at the Matlab command line and try again.
1. If the camera acquisition cannot keep up, as a last resort, try increasing `handles.computer_dependent_delay`.
