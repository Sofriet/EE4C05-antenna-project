# SatCom receiver – analog beamforming network (Student #2)

EE4C05 Electromagnetics, Antennas & Beamforming Fundamentals track.
MATLAB code for the **analog part (Q1–Q5)** of the assignment *"SatCom receiver beamformer"*.
Q6–Q8 (dipole elements, embedded patterns, analog vs digital) are not part of this code.

θA = 8°: my student number ends in 98, and the assignment rule (slide 4) gives
θA = 98 − 90 for digits above 90.

## Running the code

`main.m` runs Q1–Q5 in a few seconds and writes all figures, tables and a summary to
`results/`. `tests/run_tests.m` runs 11 self-checks of the model and the design algorithms.
Plain MATLAB (R2018b or newer), no toolboxes.

## Folder structure

```
SatCom_AnalogBFN/
├── main.m                  runs Q1–Q5, saves figures, tables and summary
├── config.m                settings: thetaA, angle grids, number of bits, output
├── questions/              one function per question
│   ├── q1_A_network.m      phi1, phi2, phi3 + port-5 beam pattern         (A1)
│   ├── q2_gain_port5.m     gain of A and B at port 5 vs thetaB           (A2)
│   ├── q3_B_network.m      phi4, phi5, VRC coupling ratio vs thetaB      (A3)
│   ├── q4_gain_port6.m     gain of B at port 6 vs thetaB (+ patterns)     (A4)
│   ├── q5_two_bit.m        2-bit phase shifters: change of Q4 (+ backup)  (A5)
│   └── results_overview.m  Q2, Q4 and Q5 merged in one figure (slides)
├── src/
│   ├── components/         directional_coupler, hybrid_3dB, phase_shifter
│   ├── array/              incident_wave (plane wave at the 4 elements)
│   ├── network/            bfn_forward (signal flow), port_weights, neutral_settings
│   ├── design/             design_A_network, design_B_network, co_phase,
│   │                       vrc_kappa, closed_form_design
│   └── utils/              quantize_phase, gain_dB, plotting / export helpers
├── tests/run_tests.m       self-checks of model and algorithms
└── results/                created by main.m
    ├── figures/            Q1_…, Q2_…, … PNG files (one per deliverable)
    ├── tables/             CSV files with all values
    ├── summary.txt         every number used in the presentation
    └── results.mat         cfg + all results
```

## Model and conventions

| Item | Convention |
|---|---|
| Geometry | element *n* at x = (n−1)d, d = λ0/2; θ from the z-axis (broadside) towards +x |
| Incident wave | V_n = exp(j k x_n sin θ) – element 4 sees the wave first (Lecture 4, slide 15) |
| 3-dB hybrid | Lecture 4, slide 27: straight path 1/√2 ∠−90°, cross path 1/√2 ∠−180° |
| Phase shifter | out = in · exp(+jφ): φ is the phase *added*, as in Lecture 4 (slide 20, slides 41–43: δn − δn−1 = β, β = −kd sin θ0). The "π/4" block of the Butler example (slides 27–28) is then a 45° delay, φ = −45°. Read as delays, all φ change sign and the gains stay the same |
| Variable-ratio coupler | same as the hybrid with coupling angle κ: straight cos κ ∠−90°, cross sin κ ∠−180°; power coupling C = sin²κ (3 dB: κ = 45°, C = 50 %) |
| Gain | G = 20 log10 \|port voltage\| for unit plane waves at the elements, in dBi (the "gain pattern" of Lecture 4; 4 co-phased elements give 6.02 dBi) |
| Components | ideal: lossless, matched, isotropic elements, no mutual coupling |

Neither the assignment nor the lectures give the phases of the variable-ratio coupler, so the
model above (the ratio changes amplitudes only, same phases as the 3-dB hybrid of slide 27) is
my assumption. A different phase convention only adds a constant to φ5 and does not change any
gain.

`NaN` in a phase or ratio column of a table means that the value does not matter at that θB
(the signal it would align is zero, or the coupler uses only one input): any value gives the
same result. Example: at θB = θA nothing of B reaches the red network, so φ4, φ5 and κ are all
free.

Network (assignment slide 3), with the names used in the code:

```
el.2 -[φ1]-> H1.top   el.1 -> H1.bot           (lower-left 3 dB)
el.4 -[φ2]-> H2.top   el.3 -> H2.bot           (upper-left 3 dB)
H2.bot -[φ3]-> H3.top   H1.bot -> H3.bot       H3.bot = PORT 5 (A)
H2.top -> H4.top        H1.top -[φ4]-> H4.bot  H4.bot -> load
H4.top -[φ5]-> VRC.top  H3.top -> VRC.bot      VRC.top = PORT 6 (B), VRC.bot -> load
```

## Method in short

With ψ = k d sin θ and Δ = ψB − ψA:

* **Q1 – A network.** Co-phase every hybrid so that all of A goes towards port 5:
  φ1 = φ2 = 90° − ψA, φ3 = 90° − 2ψA → G_A5 = 10 log10 4 = 6.02 dBi.
  Side effect: the other outputs H1.top, H2.top, H3.top carry **no A at all**.
* **Q2 – port 5.** A gets 6.02 dBi for every θB; B sees the A-beam pattern,
  |port5_B|² = 4 cos²(Δ/2) cos²Δ (0 dB SIR at θB = θA, nulls at sin θB = sin θA ± ½).
* **Q3 – B network.** It only combines the three A-free signals, so port 6 never sees A,
  whatever φ4, φ5, κ are. They are used purely to maximise B:
  φ4 co-phases H1.top/H2.top (H4), φ5 co-phases H4.top/H3.top and the VRC ratio follows the
  amplitude ratio (maximal-ratio combining):
  φ4 = 90° + 2ψB, φ5 = −90° − ψA − ψB, tan κ = 1 + cos Δ.
  `design_B_network.m` does this numerically on the actual signals (works for any setting,
  also quantized); `closed_form_design.m` is the analytic cross-check.
* **Q4 – port 6.** |port6_B|² = 4 − |port5_B|²: every bit of B power not caught by port 5 reaches
  port 6, nothing is lost in the loads. This equals the projection bound
  ‖a_B‖² − |a_Aᴴa_B|²/N, i.e. the best any lossless network can do with an exact null on A.
* **Q5 – 2-bit.** States 0/90/180/270° for all five phase shifters; the VRC ratio stays
  continuous. φ1–φ3 are rounded to the nearest state, so the blue network no longer sends all
  of A to port 5 and some A reaches the red network. Two ways to design the red network:
  * **Design 1, keep the null** (meets the port-6 requirement): try all 16 φ4/φ5 states and keep
    those for which a coupling angle κ cancels A exactly at port 6 (the two A contributions that
    the VRC adds at port 6 must be in anti-phase; κ then sets equal amplitudes). Per θB the kept
    pair with the most B gain is used.
  * **Design 2, maximise B** (requirement relaxed): the Q3 algorithm with every phase rounded as
    soon as it is computed (the next stage is designed on the real, quantized signals) and κ
    re-optimised for B. A then leaks into port 6.

  Backup outputs separate the effect of quantizing the A network (φ1–φ3) from the B network
  (φ4, φ5), give an exhaustive search over the 16 φ4/φ5 states and a 1–6-bit sweep of both designs.
  With b bits, 2^(b−1) state pairs keep the exact null, but κ is then set by the ratio of the
  φ1 and φ3 rounding errors, not by B, so the B loss of design 1 does not shrink with more bits.

## Key results for θA = 8°

| | Result |
|---|---|
| Q1 | ψA = 25.05°, **φ1 = φ2 = 64.95°, φ3 = 39.90°**; port-5 weights ½·e^(−j(n−1)ψA) |
| Q2 | G_A5 = 6.02 dBi for all θB; G_B5 = 6.02 dBi at θB = θA, null at 39.7°, ≤ −5.3 dBi beyond it |
| Q3 | φ4 = 90° + 360°·sin θB, φ5 = −90° − 180°(sin θA + sin θB), tan κ = 1 + cos(ψB − ψA); C = sin²κ from 80 % (near θA) to 0.9 % (90°) |
| Q4 | A at port 6 = 0 (−∞ dB) for all θB; G_B6 = 10log10(4 − \|V5,B\|²): 6.02 dBi at 39.7°, ≥ 4.3 dBi for θB ≥ 25°, −0.6 dBi at 0° |
| Q5 | 2-bit: φ1 = φ2 → 90°, φ3 → 0° (G_A5 = 5.27 dBi, −0.75 dB). Keep the null: only (φ4, φ5) = (0°, 270°) with κ = 12.5° or (180°, 180°) with κ = 31.5° cancel A; G_B6 changes −4.6…−1.0 dB (mean −2.1 dB), A stays at −∞. Maximise B: G_B6 changes −2.1…+0.2 dB where B is usable (θB ≥ 16.9°), but A leaks into port 6 at up to −6.1 dBi there (SIR ≥ 11.5 dB) and up to −2 dBi near θA |

## Outputs per deliverable

| Deliverable | Figure (results/figures) | Table (results/tables) |
|---|---|---|
| A1 phase values | `Q1_port5_beam_pattern.png` | `Q1_A_network_phases.csv`, `Q1_port5_element_weights.csv` |
| A2 port 5 | `Q2_gain_port5_vs_thetaB.png` | `Q2_gain_port5.csv` |
| A3 unknowns | `Q3_B_network_unknowns_vs_thetaB.png` | `Q3_B_network_vs_thetaB.csv` |
| A4 port 6 | `Q4_gain_port6_vs_thetaB.png`, `Q4b_port6_beam_patterns.png` | `Q4_gain_port6.csv` |
| A5 2-bit | `Q5_2bit_gain_port6.png`, `Q5b_breakdown.png`, `Q5c_phase_resolution_sweep.png` | `Q5_2bit_results.csv`, `Q5_2bit_A_network.csv`, `Q5_resolution_sweep.csv` |
| A2 + A4 + A5 merged | `Q2_Q4_Q5_overview.png` | |

## Link to Q6/Q7

`port_weights.m` returns the element-to-port coefficients of port 5 and port 6. By reciprocity
they are the transmit excitations, i.e. the **"Amplitude taper"** and **"Phase shift"** vectors
`[v1 v2 v3 v4]` for the Antenna Array Designer (75 Ω reference impedance and termination).
They are saved in `Q1_port5_element_weights.csv` and `Q4_port6_element_weights_vs_thetaB.csv`.
The sign convention of the tool's "Phase shift" has to match the one above.
