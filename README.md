## Magnetic stimulus generation and evaluation for physiology setups

In this repository we provide the resources for a system to generate and evaluate magnetic stimuli for physiology setups. The system consists of (1) a miniature vector magnetometer that is small enough to fit in typical physiological recording chambers, and (2) a constant-current coil driver that is suited to drive coil-systems (e.g. Helmholtz-Coils) for the generation of magnetic fields. We provide calibration routines for the magnetometer and the coil system.

### Images

<img src="https://github.com/mtahlers/magStim/blob/main/img/sensorHead.jpg" width="300">
<img src="https://github.com/mtahlers/magStim/blob/main/img/coilDriver.jpg" width="300">

_Left: sensor head of the miniature vector magnetometer. PCB diameter is 6mm. Right: coil driver module for one axis._


## Repository structure

```
├───coil_calibration      Coil calibration example in MATLAB
│
├───coil_driver           Hardware resources for the coil driver
│   └───gerber            - Gerber files for PCB
│
└───magnetometer          Resources for the magnetometer
    ├───hardware          - Hardware resources for the magnetometer
    │   └───gerber        - Gerber files for PCB
    └───software          - Software resources for the magnetometer
 	├───firmware      - AVR µC firmware for the magnetometer
        └───readout	  - example for magnetometer read-out in MATLAB 
```
