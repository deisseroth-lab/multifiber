# multifiber
A minimal GUI for doing frame-projected independent-fiber photometry

## Upcoming functionality not yet enabled
Ability to configure an arbitrary stimulation waveform to be outputted in synchrony with the digital waveforms controlling the camera and imaging LEDs.

## Troubleshooting
If the GUI crashes during initialization, there may be a problen with the
configurations that FIPGUI persists between sessions. Try running
`rmpref('FIPGUI')` at the Matlab command line and try again.