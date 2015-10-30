# multifiber
A minimal GUI for doing frame-projected independent-fiber photometry

## Troubleshooting
If the GUI crashes during initialization, there may be a problen with the
configurations that FIPGUI persists between sessions. Try running
`rmpref('FIPGUI')` at the Matlab command line and try again.