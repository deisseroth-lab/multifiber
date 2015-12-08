# multifiber
A minimal GUI for doing frame-projected independent-fiber photometry

See [link to paper].

## Background
Frame-projected independent-fiber photometry records the sum fluorescence from each of several optical fibers by imaging the fiber bundle onto a camera sensor and digitally cropping and summing the fluorescence from each fiber. Alternating excitation wavelengths for successive frames enables concurrent sampling of multiple spectral channels and/or optical stimulation.

## Scope
The software synchronizes various hardware (light sources, camera acquisition, behavoral apparatuses) by using digital and analog output voltage waveforms and reads image frames from the camera. The measure camera signal from each fiber position can be processed, visualized and accessed in real-time, and saved to hard disk for later analysis. In addition, simultaneous analog input recording is enabled.

Up to 4 analog output waveforms can be user-defined for controlling behavoral apparatuses and other hardware.

The software is based on MATLAB's GUI interface and Image and Data Acquisition toolboxes.

## Hardware requirements
Note: It may be possible to modify the software to work with other MATLAB-supported cameras and DAQ cards.
1. Hamamatsu Orca Flash4.0 V2
1. National Instruments DAQ Card (PCIe-6343-X and BNC-2090A/BNC-2110)
1. PC to support the above hardware -- see [Hamamatsu PC Recommendations](http://www.hamamatsu.com/sp/sys/en/documents/PCRecommendationforOrca-Flash4.0_20150212.pdf)

## Software requirements
1. MATLAB (tested with 2013b, 2014b)
1. MATLAB [Image Acquisition](http://www.mathworks.com/products/imaq/) toolbox and [adaptor for camera](http://www.mathworks.com/help/imaq/installing-the-support-packages-for-image-acquisition-toolbox-adaptors.html). The Image Acquisition toolbox may require the Image Processing toolbox.
1. MATLAB [Data Acquisition](http://www.mathworks.com/products/daq/) toolbox

## Installation and configuration
1. Ensure the camera and DAQ hardware are accessible using their provided software (e.g. [HCImage Live](http://hcimage.com/hcimage-overview/hcimage-live/)).
1. Ensure the MATLAB toolboxes and camera adaptor are installed (see above).
1. Run `fipgui.m`.
1. In the GUI, select the counter channels to correspond to the physical DAQ connections.

## Real-time data access
In the GUI, select a call-back function, e.g. `sample_scripts/sample_callback.m`.

## User-defined analog output voltage waveforms
Run `sample_generate_ao_waveform.m` or `sample_generate_ao_waveform_stim.m` to produce an example waveform file, then in the GUI, select that waveform `.mat` file. 

## Analog input recording
Ensure the desired physical connections are made to the DAQ analog input channels. Then, in the GUI, enable the checkbox for analog input recording. A `.csv` file will be saved along with the other acquisition data. Visualize the recorded data by using the GUI button or `plotLogFile.m`.

## Troubleshooting
1. The `tests/` directory contains tests for checking each hardware component separately.
1. If the GUI crashes during initialization, there may be a problen with the
configurations that FIPGUI persists between sessions. Try running
`rmpref('FIPGUI')` at the Matlab command line and try again.
1. Errors involving `vid = videoinput(adaptors{camDeviceN}, IDs(camDeviceN), formats{camDeviceN});`: check if IMAQ video adaptor is installed (`imaghwinfo`).
