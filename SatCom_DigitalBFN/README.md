# SatCom Digital Beamforming Network

MATLAB code for the digital beamforming network (BFN) of the EE4C05 antenna project: a 4-element uniform linear array that receives satellite A at fixed angle and satellite B at a variable angle.

## Setup

| Parameter | Value |
|---|---|
| Frequency f0 | 9 GHz (group 9) |
| Elements N | 4 |
| Spacing d | lambda0/2 |
| theta_A | 7 deg (student number 5840597) |
| theta_B | 0 .. 90 deg, step 0.01 deg |

theta is measured from the z-axis towards +x (xz-plane, azimuth 0). The array lies along x.

## Receiver ports

- **Port 5**: fixed weights `w_A` (maximum gain towards A).
- **Port 6**: weights `w_B(theta_B)` (maximum gain towards B, null towards A).

## Layout

```
SatCom_DigitalBFN/
├── figures/                  generated PNGs (600 dpi)
└── src/
    ├── main.m                all calculations (Q1-Q7)
    ├── plots.m               runs main.m, prints results, saves all figures
    ├── array_setup.m         shared parameters, steering vector, plot helpers, figure folder
    ├── weights_B_projection.m  w_B via projection onto the null space of a(theta_A)
    ├── dipole_antenna.mat    single dipole (Antenna Designer app), resonant at 9 GHz, along y
    └── dipole_antenna_array.mat  4-dipole array (Antenna Array Designer app)
```

## Usage

Requires MATLAB with the Antenna Toolbox (`pattern`, `impedance`, `EHfields`, `polarpattern`, `physconst`). `exportgraphics` needs R2020a or newer.

Run `src/plots.m` as a whole (Run button, not a selection or section). It calls `main`, which calls `array_setup`. Figures are written to `figures/`; the folder is created if missing.

Run the file as a whole because `array_setup.m` resolves `figures/` through `mfilename('fullpath')`, which can point elsewhere when only a selection is evaluated.

## Method per question

| Q | Content | Figure |
|---|---|---|
| Q1 | `w_A = a(theta_A)/‖a(theta_A)‖`, steering vector `a(θ) = exp(j k d n sin θ)` | n/a |
| Q2 | Gain of A and B at port 5, `abs(w_A' a)^2` | `q2_port5_gain` |
| Q3 | `w_B` = normalised projection of `a(theta_B)` onto the orthogonal complement of `a(theta_A)`; element 1 real and positive. No solution at theta_B = theta_A (NaN) | `q3_weights_B` |
| Q4 | Gain of B at port 6 | `q4_q5_port6_gain` |
| Q5 | Uniform amplitude (`1/sqrt(N)`) with the phases of `w_B`; compare with Q4 | `q4_q5_port6_gain`, `q5_delta_gain` |
| Q6 | Dipole elements, pattern multiplication (element gain added in dB), impedance at f0 | `q6_*` |
| Q7 | Embedded element patterns including mutual coupling, other elements terminated in 50 ohm; `g(θ)` replaces `a(θ)` | `q7_*` |

### Q6 and Q7 notes

- Element gain is taken in the xz-plane at `az = 0`, `el = 90 - theta`.
- For Q7 the embedded pattern magnitude comes from the gain and the phase from the co-polar far field `E_y` at 100 lambda0. Theta runs -90..90 deg (azimuth 180 for negative theta) and is then cropped to 0..90 deg. A phase common to all elements drops out of `abs(w' g)^2`.
- `plots.m` asserts that the array in `dipole_antenna_array.mat` matches `N` and `d` from `array_setup.m`.

## Figures

| File | Content |
|---|---|
| `q2_port5_gain.png` | Port 5 gain, isotropic elements |
| `q3_weights_B.png` | Magnitude and phase of `w_B(theta_B)` |
| `q4_q5_port6_gain.png` | Port 6 gain: null-steered vs uniform amplitude, leakage of A |
| `q5_delta_gain.png` | Gain change of B from uniform amplitude |
| `q6_dipole_3d.png`, `q6_dipole_xz_cut.png`, `q6_dipole_impedance.png` | Single dipole 3D pattern, xz cut, impedance sweep 8..10 GHz |
| `q6_port5_gain.png`, `q6_port6_gain.png`, `q6_delta_gain.png` | Dipole elements without coupling vs isotropic |
| `q7_element_patterns.png` | Embedded element patterns vs isolated dipole |
| `q7_port5_gain.png`, `q7_port6_gain.png`, `q7_delta_gain.png` | Gains with coupling vs without, and change w.r.t. isotropic |
