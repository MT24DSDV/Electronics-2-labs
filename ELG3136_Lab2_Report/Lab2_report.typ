// ELG3136 Electronics II, Lab 2: Differential Amplifier
// Compile from this folder:  typst compile Lab2_report.typ
// Pictures are in ./images, LTspice netlists in ./sim

#set document(title: "ELG3136 Lab 2: Differential Amplifier")
#set page(
  paper: "us-letter",
  margin: (x: 2.2cm, y: 2.1cm),
  numbering: "1",
  header: context {
    if counter(page).get().first() > 1 {
      set text(8.5pt, fill: luma(110))
      [ELG3136 Electronics II #h(1fr) Lab 2: Differential Amplifier]
    }
  },
)
#set text(font: "New Computer Modern", size: 10.5pt)
#set par(justify: true, leading: 0.6em, spacing: 0.9em)
#set heading(numbering: "1.1")
#show heading.where(level: 1): set text(13pt)
#show heading: set block(above: 1.3em, below: 0.7em)
#set math.equation(numbering: "(1)")
#set figure(gap: 0.55em)
#show figure.caption: set text(9pt)
#show figure.where(kind: table): set figure.caption(position: top)
#set list(indent: 0.4em, spacing: 0.7em)
#show "≈": it => text(font: "New Computer Modern Math", it)
#show table: set par(justify: false)

// Three-rule table with light row banding
#let rtable(columns: (), header: (), align-first: left, ..cells) = {
  let n = columns.len()
  let rows = calc.ceil(cells.pos().len() / n) + 1
  table(
    columns: columns,
    inset: (x: 6pt, y: 4.5pt),
    align: (x, y) => if x == 0 { align-first + horizon } else { center + horizon },
    stroke: (x, y) => (
      top: if y == 0 { 0.8pt } else if y == 1 { 0.5pt } else { none },
      bottom: if y == rows - 1 { 0.8pt } else { none },
    ),
    fill: (x, y) => if y > 0 and calc.even(y) { luma(245) },
    table.header(..header.map(h => strong(h))),
    ..cells.pos(),
  )
}
#let blank = box(width: 100%, height: 1.05em, stroke: (bottom: 0.5pt))
#let nm = text(fill: luma(110))[not measured]
#let na = text(fill: luma(110))[n/a]

// ---------------------------------------------------------------- title
#align(center)[
  #text(9.5pt, fill: luma(90))[ELG3136 Electronics II · Laboratory 2]
  #v(1pt)
  #text(17pt, weight: "bold")[Differential Amplifier with Current-Mirror Bias]
  #v(1pt)
  #text(11pt)[Lab report]
]
#v(4pt)
#table(
  columns: (auto, 1fr, auto, 1fr),
  stroke: none,
  inset: (x: 4pt, y: 5pt),
  align: (left + bottom, left + bottom, left + bottom, left + bottom),
  [Name], [Marcel Traore], [Student ID], [\#300379484],
  [Name], [Tian Li ], [Student ID], [\#300303671],
  [Date], [October 27th 2026],
)
#v(4pt)
= Introduction
The current mirror biased the differential pair at a tail current of 1.87 mA, 37% above the 1.37 mA design value. The Early effect and an estimated 6 mV $V_"BE"$ mismatch between the two discrete mirror transistors account for the difference. The measured DC operating point, the pre-lab mirror simulations and the output swing limits agree with analysis. The small-signal quantities could not be measured on the bench: the base signal in step 2 was below the oscilloscope noise floor, the only output capture was taken with the pair overdriven, and the common-mode output was not a response to the input. They are reported instead from hand analysis and from an LTspice simulation matched to the measured bias, which agree within 3%: $A_d = -77.4$ V/V, $R_"id" = 8.6$ kΩ, and a CMRR of 63.4 dB single-ended and 94.6 dB differential.

// ---------------------------------------------------------------- 2
= Objectives
- Use a BJT current mirror to supply the bias (tail) current of a differential pair.
- Measure the pair's DC operating point, input resistance, differential gain, common-mode gain and CMRR, and compare each with analysis and simulation.

// ---------------------------------------------------------------- 3
= Pre-lab: current mirror
== Hand analysis
With $V_"BE" approx 0.7$ V, the reference current set by the 6.8 kΩ resistor is
$ i_"ref" = (0 - 0.7 - (-10)) / (6.8 "kΩ") = 1.37 "mA". $
$Q_2$ stays active while its collector-emitter voltage exceeds $V_"CE,sat" = 0.2$ V:
$ V_"CE2" = 10 - i_"copy" R_x >= 0.2 "V" quad => quad 0 <= R_x <= (9.8 "V") / i_"copy" = 7.16 "kΩ". $ <eq-rx>
Above this bound $Q_2$ saturates and $i_"copy" approx 9.8 "V" \/ R_x$, for example 0.98 mA at 10 kΩ.

== Simulation
The mirror was simulated in Multisim (@fig-ms-circuit, @fig-ms-sweep) and, to separate the non-ideal effects, in LTspice with three versions of the 2N3394 model (@tab-mirror, @fig-lt-mirror; netlist in Appendix B). $V_"AF"$ was raised to $2 times 10^6$ V in every case, so the Early effect plays no role.

#figure(
  rtable(
    columns: (2.2fr, 0.95fr, 1.1fr, 0.9fr, 0.85fr, 1.1fr),
    header: ([Model], [$i_"ref"$], [$i_"copy"$ at $R_x = 1$ kΩ], [$i_"copy" \/ i_"ref"$], [Effective $beta$], [$R_x$ at $V_"CE2" = 0.2$ V]),
    [Hand analysis (ideal)], [1.37 mA], [1.37 mA], [1], [∞], [7.16 kΩ],
    [(1) 2N3394 as given, $beta_F = 121.3$], [1.380 mA], [1.337 mA], [0.969], [62], [7.36 kΩ],
    [(2) $beta_F$ raised to $10^6$], [1.380 mA], [1.359 mA], [0.985], [130], [7.24 kΩ],
    [(3) $beta_F$ raised and $I_"SE" = 0$], [1.380 mA], [1.380 mA], [1.000], [≈ ∞], [7.13 kΩ],
  ),
  caption: [Current-mirror results. Effective $beta = 2 \/ (i_"ref" \/ i_"copy" - 1)$. In all three LTspice cases $i_"copy" = 0.991$ mA at $R_x = 10$ kΩ.],
) <tab-mirror>

The ideal model (3) reproduces the hand analysis: $i_"copy" = i_"ref"$, and the saturation bound agrees within 0.5% (7.13 against 7.16 kΩ). Its $i_"ref"$ is 1.380 rather than 1.368 mA only because the model's $V_"BE"$ is 0.62 V rather than 0.7 V. Raising $beta_F$ alone is not enough. The model's base-emitter leakage term ($I_"SE" = 1.22 times 10^(-13)$ A, $N_E = 1.305$) adds about 10 µA of base current at 1.4 mA, which limits the effective $beta$ to about 130 in case (2) and to about 62 with the default $beta_F$ in case (1). The two Multisim results correspond to these cases: the operating point of @fig-ms-circuit (1.359 mA) to case (2), and the sweep of @fig-ms-sweep (flat at 1.34 mA) to case (1), so the sweep was run on the unedited model. In every case $Q_2$ leaves the active region between 7.1 and 7.4 kΩ.

#grid(
  columns: (0.85fr, 1.15fr),
  gutter: 12pt,
  align: bottom,
  [#figure(image("images/prelab_multisim_circuit.png", width: 100%),
    caption: [Multisim mirror at $R_x = 1$ kΩ with $beta_F$ raised: $i_"ref" = 1.38$ mA, $i_"copy" = 1.359$ mA.]) <fig-ms-circuit>],
  [#figure(image("images/prelab_multisim_sweep.png", width: 100%),
    caption: [Multisim sweep of $R_x$ (unedited model): $i_"copy"$ is flat at 1.34 mA up to about 7 kΩ, then falls as $Q_2$ saturates. The negative sign is the reference direction.]) <fig-ms-sweep>],
)
#figure(image("images/sim_mirror_ltspice.png", width: 100%),
  caption: [LTspice sweep of $R_x$ for the three models of @tab-mirror (green: case 1, blue: case 2, red: case 3). The horizontal axis $V_"rx"$ is $R_x$ in kΩ; the current is plotted negative to match the Multisim sign convention.]) <fig-lt-mirror>

// ---------------------------------------------------------------- 4
= Circuit and setup
The mirror ($R_K = 6.8$ kΩ, emitters at −10 V) sets the tail current of the $Q_1$, $Q_2$ pair (2N3904, $R_C = 2.2$ kΩ, $R_B = 2$ MΩ to +10 V, $C_1 = 10$ µF), as shown in @fig-schematic. In differential mode the base of $Q_2$ was grounded at A; in common mode it was moved to B. $R_S$ was a decade resistance box. For step 2 it was set to 9 kΩ with an 820 kΩ resistor in series, so $R_S = 829$ kΩ. Component and supply values were not measured, so nominal values are used throughout.

*Simulation of the amplifier.* The circuit of @fig-schematic was simulated in LTspice (Appendix B). To compare like with like, the simulation was matched to the measured bias. The pair transistors use $beta_F = 137$ and 129, which give the measured effective $beta$ of 156 and 147 at $V_"CE" approx 11$ V with $V_A = 74$ V. The mirror's output transistor has 1.28 times the area of the reference transistor, which represents the 6 mV $V_"BE"$ mismatch estimated in @sec-dc. The DC agreement in @tab-bias is therefore by construction; the small-signal results are the prediction being tested. Gains were computed with an AC analysis at 5 kHz, and amplitudes, waveforms and output limits with a transient analysis.

#figure(image("images/manual_fig7_diffamp.png", width: 50%),
  caption: [Differential amplifier with current-mirror tail (Lab Manual 2, Figure 7).]) <fig-schematic>
#align(center, block(width: 82%, grid(
  columns: (0.72fr, 1.28fr),
  gutter: 12pt,
  align: bottom,
  [#figure(image("images/bench_breadboard_1.jpg", width: 100%),
    caption: [Breadboard build with supply and probe leads.]) <fig-bb1>],
  [#figure(image("images/bench_breadboard_2.jpg", width: 100%),
    caption: [Breadboard with the oscilloscope probe connected for the AC measurements.]) <fig-bb2>],
)))

// ---------------------------------------------------------------- 5
= Results

== DC operating point and linear range (procedure step 1) <sec-dc>
@tab-dc lists the DC voltages measured with no input signal, in the format of the lab manual. Since $R_B$ is the only DC path into each base, the base current follows from the base voltage and the collector current from the drop across $R_C$:
$ I_C = (10 - V_C) / R_C, quad I_B = (10 - V_B) / R_B, quad beta = I_C / I_B, quad g_m = I_C / V_T. $

#figure(
  rtable(
    columns: (0.8fr, 0.8fr, 0.8fr, 0.8fr, 2.2fr, 1.2fr),
    header: ([$V_"C1"$], [$V_"C2"$], [$V_"B1"$], [$V_"B2"$], [Linear range of output signal], [Voltage offset]),
    align-first: center,
    [7.88 V], [8.00 V], [−2.33 V], [−2.33 V], [5.88 to 10 V per collector \ (±2.0 V about the Q-point)], [−0.12 V \ ($V_"C1" - V_"C2"$)],
  ),
  caption: [Step 1 results. The linear range is derived below.],
) <tab-dc>

#figure(
  rtable(
    columns: (1.6fr, 1fr, 1fr, 1.3fr, 1.2fr),
    header: ([Parameter], [$Q_1$ (bench)], [$Q_2$ (bench)], [Simulation \ ($Q_1$, $Q_2$)], [Ideal design]),
    [$V_C$], [7.88 V], [8.00 V], [7.89 V, 8.01 V], [8.50 V],
    [$V_B$], [−2.33 V], [−2.33 V], [−2.32 V, −2.32 V], [],
    [$I_C$], [0.964 mA], [0.909 mA], [0.960, 0.905 mA], [0.684 mA],
    [$I_B$], [6.17 µA], [6.17 µA], [], [],
    [$beta$], [156], [147], [156, 147], [],
    [$g_m$ ($V_T = 26$ mV)], [37.1 mS], [35.0 mS], [], [26.3 mS],
    [$r_pi = beta \/ g_m$], [4.22 kΩ], [4.22 kΩ], [], [],
    [Tail current $I_T$], table.cell(colspan: 2)[1.87 mA (1.885 mA with base currents)], [1.878 mA], [1.37 mA],
    [Common emitters $V_E$], table.cell(colspan: 2)[≈ −3.0 V (from $V_B - V_"BE"$, not recorded)], [−2.98 V], [],
  ),
  caption: [Bias parameters calculated from @tab-dc, the bias-matched simulation, and the ideal design ($I_T = 9.3 "V" \/ 6.8 "kΩ"$ split equally).],
) <tab-bias>

*Tail current.* The measured $I_T = 1.87$ mA is 37% above the ideal 1.37 mA. Two effects can be predicted. The mirror's output transistor runs at $V_"CE" approx 7.0$ V against 0.67 V for the reference transistor, which raises its current by $(1 + 7.0\/74)\/(1 + 0.67\/74) = 1.084$ for $V_A = 74$ V, and a finite $beta approx 150$ lowers it by 1.3%. Together they give 1.46 mA. The remaining factor of 1.28 corresponds to a $V_"BE"$ mismatch of $V_T ln 1.28 = 6.4$ mV between the two mirror transistors, which is typical of unmatched, thermally separate 2N3904s. An $R_K$ of about 5 kΩ instead of 6.8 kΩ would have the same effect; $R_K$ was not measured.

*Offset.* Both bases are fed through 2 MΩ resistors with the same voltage drop, so both draw 6.17 µA and the collector currents split in the ratio of the $beta$ values. $I_"C1"$ is 5.8% above $I_"C2"$, which gives $V_"C1" - V_"C2" = -0.12$ V. Referred to the input, the offset is $0.12 "V" \/ 77.4 approx 1.5$ mV.

*Linear range of the output.* Each collector can only move between 10 V (that transistor cut off) and $10 - I_T R_C = 5.88$ V (that transistor carrying all of $I_T$). Around the Q-points of 7.88 and 8.00 V this allows ±2.0 V per collector (4.1 Vpp) and ±4.12 V differential. Because $i_"C1" = (I_T \/ 2)(1 + tanh(v_d \/ 2V_T))$, the gain falls gradually before these limits are reached; @tab-range gives the amplitudes for a given gain error.

#figure(
  rtable(
    columns: (1fr, 1fr, 1.4fr, 1.4fr),
    header: ([Gain error], [Max $v_d$], [Max output, one collector], [Max output, differential]),
    [1%], [18 mVpp], [0.71 Vpp], [1.42 Vpp],
    [5%], [42 mVpp], [1.56 Vpp], [3.13 Vpp],
    [10%], [61 mVpp], [2.16 Vpp], [4.33 Vpp],
  ),
  caption: [Linear range of the pair at the measured bias. The manual's 20 mVpp test input sits near the 1% row.],
) <tab-range>

The simulation with ±150 mV at the base (@fig-lin-sim) drives the pair fully: $V_"C1"$ swings from 5.90 to 9.99 V and the differential output from −4.09 to +4.07 V, within 0.05 V of the predicted limits. The one bench capture with a large input (@fig-vo, 197 mVpp input) shows 3.8 Vpp at one collector, close to the 3.94 Vpp large-signal prediction and to the 4.12 Vpp limit. This capture is used only as a check of the output limit: this far into the nonlinear region, $3.8 "V" \/ 0.197 "V" = 19.3$ V/V is not a small-signal gain.

#grid(
  columns: (1.15fr, 0.85fr),
  gutter: 12pt,
  align: bottom,
  [#figure(image("images/sim_linear_range.png", width: 100%),
    caption: [Simulated linear-range test: ±150 mV differential input (bottom) and differential output (top), which flattens at about ±4.08 V.]) <fig-lin-sim>],
  [#figure(image("images/scope_vo_3v8.jpg", width: 100%),
    caption: [Bench, overdriven: CH1 (yellow, 100 mV/div) input, 197 mVpp; CH2 (green, 5 V/div) one collector, 3.8 Vpp, inverted.]) <fig-vo>],
)

== Signal source and input resistance (procedure step 2)
The function generator was set to a 5 kHz, 200 mVpp sine with the High Z output setting; the oscilloscope read 201 mVpp (@fig-gen). $R_S$ was then increased to bring $v_d$ at the base of $Q_1$ down toward the 20 mVpp target. @fig-rs-seq and @tab-rs show the readings during this adjustment.

#grid(
  columns: (1fr, 0.8fr, 1fr),
  gutter: 10pt,
  align: bottom,
  [#figure(image("images/scope_gen_201mv.jpg", width: 100%),
    caption: [Generator output with High Z: 201 mVpp at 5 kHz.]) <fig-gen>],
  [#figure(image("images/bench_decade_box.jpg", width: 100%),
    caption: [Decade box used for $R_S$, set to 9 kΩ.]) <fig-rs>],
  [#figure(image("images/bench_rs_circuit.jpg", width: 100%),
    caption: [Circuit with $R_S$ and the 10 µF coupling capacitor.])],
)

#figure(
  grid(
    columns: (1fr, 0.82fr, 1fr),
    gutter: 6pt,
    align: bottom,
    [#image("images/scope_rs_201mv.jpg", width: 100%) (a)],
    [#image("images/scope_rs_68mv.jpg", width: 100%) (b)],
    [#image("images/scope_rs_36mv.jpg", width: 100%) (c)],
  ),
  caption: [Adjusting $R_S$. CH1 (yellow) is the base of $Q_1$ and CH2 (green) is the source. (a) 201 mVpp at the base with a visible sine; (b) 68 mVpp at 100 mV/div and (c) 36 mVpp at 50 mV/div, both with no visible sine.],
) <fig-rs-seq>

#figure(
  rtable(
    columns: (1.3fr, 1fr, 1fr, 1fr, 1fr),
    header: ([Capture], [$v_d$ (CH1)], [CH1 scale], [$v_s$ (CH2)], [Sine visible]),
    [(a)], [201 mVpp], [100 mV/div], [225 mVpp], [Yes],
    [(b)], [68 mVpp], [100 mV/div], [237 mVpp], [No],
    [(c) $R_S = 829$ kΩ], [36 mVpp], [50 mV/div], [235 mVpp], [No],
  ),
  caption: [Readings during the $R_S$ adjustment. The lowest $v_d$ reached was 36 mVpp.],
) <tab-rs>

Using reading (c), with $k = v_d \/ v_s = 36 \/ 235 = 0.153$, the manual's divider equation rearranges to
$ R_p = R_"id" || R_B = (k R_S) / (1 - k) = (0.153 times 829 "kΩ") / 0.847 = 150 "kΩ", quad R_"id" = (R_p R_B) / (R_B - R_p) = 162 "kΩ". $
The expected input resistance with $Q_2$'s base grounded is
$ R_"id" = 2 r_pi = (2 V_T) / I_B = (2 times 26 "mV") / (6.17 "µA") = 8.43 "kΩ", $
and the simulation gives 8.64 kΩ. At $R_S = 829$ kΩ the true $v_d$ was therefore only about 2.4 mVpp (@fig-vd-plot), far below the 36 mVpp noise floor of the oscilloscope in Normal acquisition. Captures (b) and (c) show no sine, and the reading roughly halved with the vertical scale. The 36 mVpp reading is noise, the true $k$ is smaller than 0.153, and the bench result is only an upper bound: $R_"id" <= 162$ kΩ. The 20 mVpp target needed $R_S approx 77$ kΩ, which the decade box alone can provide (its ×10000 dial reaches about 100 kΩ), and Averaging acquisition (manual step 3f) would have lowered the noise floor.

Two further observations. The source read 225 to 237 mVpp although a High Z generator set to 200 mVpp cannot deliver more, because the peak-to-peak measurement includes the noise spikes. Capture (a), with a clean 201 mVpp at the base, was taken at a small, unrecorded $R_S$; with $R_"id" approx 8.6$ kΩ it implies $R_S approx 1$ kΩ.

#figure(image("images/plot_vd_vs_rs.svg", width: 92%),
  caption: [Predicted $v_d = v_s R_p \/ (R_S + R_p)$ for $v_s = 200$ mVpp and $R_"id" = 8.4$ kΩ. The 20 mVpp target needs $R_S approx 76$ kΩ; at 829 kΩ the signal (≈ 2 mVpp) is far below the 36 mVpp noise floor, which is what was measured.]) <fig-vd-plot>

== Differential gain (procedure step 3) <sec-gain>
*Bench.* No valid small-signal gain was recorded. The input values noted for this step ($v_d = 36$ mVpp, $v_s = 235$ mVpp) come from the $R_S = 829$ kΩ setting, where $v_d$ is noise, and the output value (3.8 Vpp) comes from the overdriven capture of @fig-vo. Their ratios (106 and 16.2 V/V) do not describe one operating condition and are not reported as results. A correct measurement needs $R_S approx 77$ kΩ ($v_d approx 20$ mVpp) and the differential output measured as CH1 − CH2.

*Expected gain.* For matched transistors at the measured bias,
$ g_m = (I_"C1" + I_"C2") / (2 V_T) = (0.936 "mA") / (26 "mV") = 36.0 "mS", quad A_d = (v_"o1" - v_"o2") / v_d = -g_m R_C = -79.2 "V/V", $
or −39.6 V/V at each collector (−57.9 V/V at the ideal 1.37 mA bias). Including the transistors' output resistance, $r_o = (V_A + V_"CE") \/ I_C = (74 + 10.9) "V" \/ 0.936 "mA" = 90.7$ kΩ, in parallel with $R_C$ gives $A_d = -77.4$ V/V.

*Simulation.* With $v_s = 200$ mVpp and $R_S = 76$ kΩ, the AC analysis gives $A_d = -77.4$ V/V, −38.7 V/V at each collector, and $A_"ds" = -7.86$ V/V, with the output inverted (180°). The transient analysis (@fig-dm-sim) gives $v_d = 20.6$ mVpp, $v_"o1" = 0.79$ Vpp and $v_"o1" - v_"o2" = 1.57$ Vpp, a gain of 76.4 V/V. The 1.2% lower value is the compression expected at this input level (@tab-range, 1% row).

#figure(image("images/sim_dm_waveforms.png", width: 84%),
  caption: [Simulated differential mode, $R_S = 76$ kΩ: base of $Q_1$ (top, 20.6 mVpp around −2.317 V) and differential output (bottom, 1.57 Vpp, inverted).]) <fig-dm-sim>

#figure(
  rtable(
    columns: (1fr, 1fr, 1fr, 2.4fr),
    header: ([$V_o$], [$A_d$], [$A_"ds"$], [Expected voltage gain]),
    align-first: center,
    [1.57 Vpp], [−77.4 V/V], [−7.86 V/V], [$-g_m R_C = -79.2$ V/V \ (−77.4 V/V including $r_o$)],
  ),
  caption: [Step 3 results in the manual's format. No valid bench measurement was obtained; the values are from the bias-matched simulation ($v_s = 200$ mVpp, $R_S = 76$ kΩ, differential output).],
) <tab-gain>

== Common-mode gain and CMRR (procedure step 4)
*Bench.* With $Q_2$'s base moved to B and $R_S$ still at 829 kΩ, the output kept clipping. The captured waveform (@fig-cm) is 520 mVpp at one collector, but its period is about 2.4 div at 50 µs/div (≈ 8.4 kHz) rather than 200 µs, and the collector sat at about 9.0 V DC (the CH2 trigger level, 9.07 V, lies on the trace) instead of 7.9 to 8.0 V, that is about 0.48 mA instead of 0.94 mA. The waveform is therefore not the response to the 5 kHz input, and the operating point had shifted. The base signal was not recorded (CH1: No signal). For comparison, the common-mode input resistance, $(R_B \/ 2) || (beta + 1) R_o approx 0.87$ MΩ, is comparable to $R_S$, so the bases would have seen about 120 mVpp and the expected single-ended output was about 3 mVpp. $A_"cm"$ and the CMRR were therefore not measured.

#figure(image("images/scope_cm_520mv.jpg", width: 46%),
  caption: [Bench, common mode: one collector (CH2, DC coupling, 500 mV/div), 520 mVpp, distorted, period ≈ 120 µs, DC level ≈ 9.0 V.]) <fig-cm>

*Expected values.* The mirror's output resistance is $R_o = (V_A + V_"CE") \/ I_T = (74 + 7.0) "V" \/ 1.87 "mA" = 43$ kΩ. For one collector,
$ A_"cm" approx R_C / (2 R_o) = (2.2 "kΩ") / (86.5 "kΩ") = 0.025 "V/V", quad "CMRR" = 20 log abs(A_"d,se") / abs(A_"cm") = 63.6 "dB". $
For the differential output with perfectly matched halves $A_"cm" = 0$ and the CMRR is infinite. The measured 5.8% $g_m$ mismatch gives $A_"cm,d" approx 0.058 times R_C \/ (2 R_o) = 0.0015$ V/V and a CMRR of about 94 dB.

*Simulation.* The AC analysis gives $A_"cm" = 0.0261$ V/V at one collector and 0.00144 V/V differential, so the CMRR is 63.4 dB single-ended and 94.6 dB differential, within 0.3 dB of the hand estimates.

#figure(
  rtable(
    columns: (1.4fr, 1.6fr, 1.6fr),
    header: ([$v_o$], [$A_"cm"$], [CMRR (dB)]),
    align-first: center,
    [5.2 mVpp (one collector, $v_"cm" = 200$ mVpp)], [0.0261 V/V (one collector) \ 0.00144 V/V (differential)], [63.4 (single-ended) \ 94.6 (differential)],
  ),
  caption: [Step 4 results in the manual's format, from the bias-matched simulation. The bench common-mode measurement was not valid.],
) <tab-cm>

// ---------------------------------------------------------------- 6
= Comparison of results
#figure(
  rtable(
    columns: (1.7fr, 1.5fr, 1.2fr, 1.3fr, 1.4fr),
    header: ([Quantity], [Hand analysis], [Simulation], [Bench], [Assessment]),
    [Mirror $i_"copy" \/ i_"ref"$], [1], [1.000 (ideal model)], [#na], [Agrees],
    [Mirror $R_x$ bound], [7.16 kΩ], [7.13 kΩ], [#na], [Within 0.5%],
    [Tail current $I_T$], [1.37 mA (1.46 with $V_A$, $beta$)], [1.878 mA (matched)], [1.873 mA], [37% above design],
    [$V_"C1"$, $V_"C2"$], [8.50 V (ideal)], [7.89, 8.01 V], [7.88, 8.00 V], [Follows $I_T$],
    [Offset $V_"C1" - V_"C2"$], [0], [−0.120 V], [−0.12 V], [$beta$ mismatch],
    [Output limits, one collector], [5.88 to 10 V], [5.90 to 9.99 V], [3.8 Vpp (overdriven)], [Agrees],
    [$R_"id"$], [8.43 kΩ], [8.64 kΩ], [≤ 162 kΩ], [Bench: bound only],
    [$A_d$], [−79.2 V/V (−77.4 with $r_o$)], [−77.4 V/V], [#nm], [Hand and sim agree],
    [$A_"ds"$ at $R_S = 76$ kΩ], [−7.70 V/V], [−7.86 V/V], [#nm], [Within 3%],
    [$A_"cm"$, one collector], [0.025 V/V], [0.026 V/V], [#nm], [Within 3%],
    [CMRR, single-ended], [63.6 dB], [63.4 dB], [#nm], [Agrees],
    [CMRR, differential], [∞ ideal, ≈ 94 dB with mismatch], [94.6 dB], [#nm], [Agrees],
  ),
  caption: [Hand analysis, simulation and bench results.],
) <tab-compare>

= Discussion
- *Bias.* The 37% excess tail current is not a fault of the circuit. The Early effect accounts for 8%, and the rest corresponds to a 6 mV $V_"BE"$ mismatch between the discrete mirror transistors, which an integrated mirror (matched, thermally coupled devices) would avoid. The higher current raises $g_m$, so the expected $A_d$ rises from −57.9 to −79.2 V/V.
- *Offset.* With current-fed bases, the 6% $beta$ mismatch (156 against 147) sets a 6% collector-current mismatch and the −0.12 V output offset (about 1.5 mV at the input). The manual's advice to choose transistors with close $beta$ addresses exactly this.
- *Why the bench gain and CMRR failed.* In step 2, $R_S$ was about ten times too large (829 kΩ against 77 kΩ), so $v_d$ fell below the noise floor of Normal acquisition. In step 3 the recorded input and output came from different settings, and the only output capture was overdriven. In step 4 the output was not a response to the input and the bias had shifted. Repeating steps 2 to 4 with $R_S approx 77$ kΩ from the decade box, Averaging acquisition, the differential output measured with CH1 − CH2, and in common mode a small $v_s$ with both bases recorded would give valid measurements.
- *Simulation.* Matched to the measured bias, the simulation reproduces every hand estimate within 3%. The 2% gap between $-g_m R_C$ and the simulated $A_d$ is the transistors' output resistance, and including $r_o$ closes it. The pre-lab simulations show that a SPICE model's base-current terms ($I_"SE"$ as well as $beta_F$) must be removed for a mirror to copy its reference exactly.

= Conclusion
The current mirror and the differential pair behave as analysed. In simulation the ideal mirror copied its reference exactly and stayed active up to $R_x = 7.13$ kΩ, against 7.16 kΩ by hand; the 2N3394 model's base-current terms explain the lower copies obtained with the default model. On the bench the mirror delivered 1.87 mA, 37% above design, consistent with the Early effect and a 6 mV mismatch between the discrete mirror transistors. The DC operating point, the −0.12 V offset and the output limits of 5.88 to 10 V per collector were measured or confirmed. The input resistance, differential gain and CMRR could not be measured reliably because of the source resistance, the oscilloscope noise floor and an overdriven or unstable output. From analysis and the bias-matched simulation they are $R_"id" approx 8.6$ kΩ, $A_d approx -77$ V/V and a CMRR of about 63 dB single-ended (95 dB differential).

// ---------------------------------------------------------------- appendix
#pagebreak(weak: true)
#set heading(numbering: none)
= Appendix A: Bench notes
Handwritten notes taken during the lab, used for @tab-dc and @tab-rs.

#figure(image("images/notes_step1_dc.png", width: 62%),
  caption: [Step 1: $V_"C1"$, $V_"C2"$, $V_"B1"$, $V_"B2"$ and the 0.12 V offset.])
#figure(image("images/notes_step2_rs.png", width: 74%),
  caption: [Step 2: final source resistance, $R_S$ = 9 kΩ + 820 kΩ.])
#figure(image("images/notes_step3_gain.png", width: 66%),
  caption: [Step 3: $v_d = 36$ mV, $v_s = 235$ mV and $V_o = 3.8$ V (see @sec-gain for why these are not used as a gain).])

#pagebreak(weak: true)
= Appendix B: LTspice netlists
#set text(6.2pt)
#columns(2, gutter: 14pt)[
  *Current mirror sweep* (`sim/mirror_sweep.cir`)
  #raw(read("sim/mirror_sweep.cir"), block: true)
  *Differential amplifier, AC analysis* (`sim/diffamp_ac.cir`)
  #raw(read("sim/diffamp_ac.cir"), block: true)
  *Differential amplifier, transient analysis* (`sim/diffamp_tran.cir`)
  #raw(read("sim/diffamp_tran.cir"), block: true)
]
