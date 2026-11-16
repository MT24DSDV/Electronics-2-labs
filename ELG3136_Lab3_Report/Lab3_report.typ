// ELG3136 Electronics II, Lab 3: Frequency Response
// Compile from this folder:  typst compile Lab3_report.typ
// Pictures are in ./images, LTspice netlists in ./sim

#set document(title: "ELG3136 Lab 3: Frequency Response")
#set page(
  paper: "us-letter",
  margin: (x: 2.2cm, y: 2.1cm),
  numbering: "1",
  header: context {
    if counter(page).get().first() > 1 {
      set text(8.5pt, fill: luma(110))
      [ELG3136 Electronics II #h(1fr) Lab 3: Frequency Response]
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
  #text(9.5pt, fill: luma(90))[ELG3136 Electronics II · Laboratory 3]
  #v(1pt)
  #text(17pt, weight: "bold")[Frequency Response of a \ Common-Emitter BJT Amplifier]
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
  [Date], [November 10th 2026],
)
#v(4pt)
= Introduction
The measured gain magnitude was 107.7 V/V at 5 kHz and 101.5 V/V at 50 kHz, compared with 127 V/V from hand analysis. The low-frequency sweep shows the expected roll-off; interpolation gives a lower 3-dB frequency of approximately 666 Hz when the recorded 5 kHz gain is used as the reference. The notes mark 540 Hz at the lower end and 295 kHz at the upper end, but the recorded amplitudes do not establish these as a consistent pair of 3-dB cutoffs. In particular, the high-frequency sweep used a different input amplitude, 20 mVpp. The measured curves, the marked cutoff values and the calculations below are kept separate so that the comparison with simulation uses explicit reference gains.

= Objectives
- Characterize the voltage gain of a common-emitter BJT amplifier as a function of input frequency.
- Determine the mid-band gain and the lower and upper 3-dB frequencies, and compare hand analysis, Multisim and LTspice.

= Pre-lab: frequency response
== Hand analysis
With the capacitors open at DC, the bias divider has the Thevenin equivalent
$ V_"Th" = 15 times 12/34 = 5.29 "V", quad R_B = 22 "kΩ" || 12 "kΩ" = 7.76 "kΩ". $
Using $beta = 150$, $V_"BE" = 0.7$ V and $R_E = 4.3$ kΩ gives
$ I_B = (V_"Th" - V_"BE") / (R_B + (beta + 1)R_E) = 6.99 "µA", quad I_C = beta I_B = 1.05 "mA". $
The emitter, base and collector voltages are 4.54 V, 5.24 V and 11.54 V. Since $V_"CE" approx 7.00$ V and $V_"CB" approx 6.30$ V, the transistor is forward active. With $V_T = 26$ mV and $V_A = 74$ V,
$ g_m = I_C / V_T = 40.3 "mS", quad r_pi = beta / g_m = 3.72 "kΩ", quad r_o = V_A / I_C = 70.6 "kΩ". $
At mid-band, $C_1$, $C_2$ and $C_E$ are short circuits and the transistor capacitances are open. The gain from the base to the output is
$ A_m = -g_m(R_C || R_L || r_o) = -(40.3 "mS")(3.15 "kΩ") approx -127 "V/V". $
Neglecting $r_o$ gives −133 V/V, about 5% higher. The gain magnitude in decibels is $20 log_10 127 = 42.1$ dB.

#figure(image("images/prelab_p3_0.png", width: 80%), caption: [Mid-band small-signal circuit from the Lab 3 pre-lab. The emitter is at AC ground and the collector sees $R_C || R_L || r_o$.])

== Low- and high-frequency limits
As $f -> 0$, the input and output coupling capacitors open, so $A_v -> 0$. Their two zeros at the origin give an ultimate +40 dB/decade slope below the lowest pole. Over the practical low-frequency range, the output coupling capacitor is already effectively shorted and the emitter bypass capacitor sets the dominant roll-off.

At high frequency the base-emitter capacitance $C_pi$ and base-collector capacitance $C_mu$ must be retained. The pre-lab estimates are $C_pi approx 19$ pF and $C_mu approx 1.8$ pF. Miller's approximation gives an input capacitance
$ C_"in" approx C_pi + C_mu(1 - A_m) approx 249 "pF". $
This capacitance acts with the resistance driving the base. The ideal source in the LTspice file therefore cannot be assumed to give the same upper cutoff as a physical generator and breadboard. In the high-frequency limit, the internal capacitances suppress $v_pi$ and the output, so $A_v -> 0$.

== Multisim simulation
The pre-lab circuit and its pole-zero analysis are shown in @fig-ms and @fig-pz. The oscilloscope result gives 19.8 mVpp at the base and 2.47 Vpp at the output, corresponding to a gain magnitude of 124.7 at 5 kHz, with inversion. This is a simulation result, not a bench measurement.

#figure(image("images/prelab_p3_1.png", width: 62%), caption: [Multisim circuit from the pre-lab: 2N3904, 15 V supply and 10 µF coupling and bypass capacitors.]) <fig-ms>

#figure(rtable(
 columns: (0.7fr, 1.8fr, 1.2fr, 1fr),
 header: ([Term], [Origin], [$s$ (rad/s)], [$abs(s) \/ (2 pi)$]),
 [$z_1$, $z_2$], [Coupling capacitors], [0], [0 Hz],
 [$z_3$], [Emitter bypass network], [−19.3], [3.07 Hz],
 [$z_4$], [$C_mu$ feedforward (RHP)], [$2.19 times 10^10$], [3.49 GHz],
 [$p_1$], [Output coupling], [$-2.12 times 10^(-2)$], [3.38 mHz],
 [$p_2$], [Input coupling], [−15.8], [2.51 Hz],
 [$p_3$], [Dominant low-frequency pole], [$-6.08 times 10^3$], [968 Hz],
 [$p_4$], [Dominant high-frequency pole], [$-2.07 times 10^7$], [3.29 MHz],
 [$p_5$], [Higher-frequency pole], [$-7.57 times 10^9$], [1.20 GHz],
), caption: [Poles and zeros reported in the Multisim pre-lab. The very large numerical roots excluded there are not used in the Bode reconstruction.]) <tab-pz>

The reconstructed magnitude gives $f_L approx 970$ Hz and $f_H approx 3.28$ MHz. After the 3.38 mHz pole, the slope is +20 dB/decade up to 2.51 Hz, flat to 3.07 Hz, +20 dB/decade to 968 Hz, and approximately flat through mid-band. It then falls at −20 dB/decade above the dominant upper pole. The higher pole and right-half-plane zero change the asymptotic slope again beyond 1 GHz.

= Circuit and setup
The nominal circuit uses $V_"CC" = 15$ V, $R_1 = 22$ kΩ, $R_2 = 12$ kΩ, $R_C = 3.3$ kΩ, $R_E = 4.3$ kΩ, $R_L = 4.7$ MΩ and $C_1 = C_2 = C_E = 10$ µF. These are the values in the saved netlists and pre-lab schematic. The manual's parts list states 4.2 kΩ for the emitter resistor; the analysis here follows the 4.3 kΩ circuit actually simulated.

*Signal definition.* Let $v_s$ be the voltage on the generator side of $C_1$, and $v_b$ the voltage at the external base. The saved LTspice sweep measures $v_o/v_s$, whereas the manual's oscilloscope procedure measures $v_o/v_b$. At mid-band they are nearly equal. At low frequency their distinction matters because the source-to-output transfer includes the input coupling capacitor.

*Bench procedure.* The manual specifies a 5 kHz, 10 mVpp sine, the generator's High Z display setting, AC-coupled scope channels and averaging. The generator has a nominal 50 Ω output resistance; High Z changes the displayed amplitude convention and does not remove this resistance. The low-frequency sweep uses 200 Hz steps, and the high-frequency sweep starts at 50 kHz with 5 kHz steps. The measured input amplitude must be used at each frequency. The recorded low-frequency sweep instead uses 500 Hz steps down to 1 kHz, then 100 Hz steps. The high-frequency record uses 10 kHz steps from 5 to 325 kHz and explicitly states a 20 mVpp input.

*LTspice simulation.* The saved AC sweep runs from 0.1 Hz to 10 GHz at 100 points per decade with an ideal 1 V AC source. The transient run uses 10 mVpp at 5 kHz. Both use the same explicit 2N3904 model, with $beta_F = 416.4$, $V_"AF" = 74.03$ V and $R_b = 10$ Ω. These model parameters differ from the hand-analysis assumption $beta = 150$; no bench bias matching was performed.

= Results
== DC operating point (low-frequency procedure step 1)
The hand-analysis values are compared with the saved LTspice operating point in @tab-dc. The bench transistor's $beta$ and terminal voltages were not recorded. The simulated effective $beta = I_C \/ I_B = 143.6$ is much lower than the model parameter $beta_F = 416.4$, because the full model includes additional base-current terms; $beta_F$ alone is not the operating-point current gain.

#figure(rtable(
 columns: (1.5fr, 1fr, 1fr, 1fr),
 header: ([Parameter], [Hand analysis], [LTspice], [Bench]),
 [$V_B$], [5.24 V], [5.24 V], [not recorded],
 [$V_E$], [4.54 V], [4.57 V], [not recorded],
 [$V_C$], [11.54 V], [11.52 V], [not recorded],
 [$I_C$], [1.05 mA], [1.056 mA], [not recorded],
 [$beta = I_C \/ I_B$], [150 (assumed)], [143.6], [not recorded],
), caption: [DC operating point. Hand values use the pre-lab assumptions; simulation values are from the saved operating-point file.]) <tab-dc>

== Mid-band gain (low-frequency procedure steps 2 and 3)
*Bench.* At 5 kHz the notes give 1.077 Vpp output and a gain magnitude of 107.7 V/V, consistent with a 10 mVpp input. This gain is 15.2% below the hand estimate of 127 V/V. The separate 50 kHz reading is 1.015 Vpp and 101.5 V/V, 5.8% (0.52 dB) below the 5 kHz gain. The notes record amplitude ratios; the expected phase inversion is not independently documented by these tables.

*Simulation.* The saved transient log gives $v_s = 9.99952$ mVpp and $v_o = 1.26358$ Vpp over 0.2 to 1 ms. Their ratio is
$ abs(A_"5 kHz") = (1.26358 "V") / (9.99952 "mV") = 126.36 "V/V". $
This differs from the hand estimate of 127 by 0.5%. The output is inverted (@fig-tran). The AC gain at 5 kHz is 125.87 V/V, 0.4% below the transient peak-to-peak ratio; the latter is a finite-amplitude result over the saved time window. The AC sweep reaches a maximum of 42.065 dB, or 126.84 V/V; the 5 kHz transient is consistent with the nearly flat mid-band response.

#figure(rtable(
 columns: (1fr, 1fr, 1fr, 1fr),
 header: ([Theoretical gain], [Multisim at 5 kHz], [LTspice transient], [Measured gain]),
 [−127 V/V], [≈ −124.7 V/V], [≈ −126.36 V/V], [107.7 V/V (magnitude)],
), caption: [Mid-band gain comparison corresponding to manual Table 2. Theoretical and simulated signs indicate inversion; the bench value is a recorded magnitude.])

#figure(image("images/transient.svg", width: 100%), caption: [Saved LTspice transient data at 5 kHz. The 10 mVpp input and approximately 1.264 Vpp output are plotted on separate scales.]) <fig-tran>

== Low-frequency response (procedure step 4)
The lower cutoff is defined by $abs(A_v) = abs(A_m)/sqrt(2)$, a 3.010 dB drop from the reference gain. The bench values in @tab-bench-low are transcribed from the handwritten record. The gain column is retained as written; small differences from output divided by exactly 10 mV imply input amplitudes near 10.0–10.1 mV or rounding. Individual input measurements were not recorded in the table.

#figure(rtable(
 columns: (1fr, 1fr, 1fr, 1fr),
 header: ([Frequency], [Recorded output], [Recorded gain (V/V)], [Gain (dB)]),
 [5 kHz], [1077 mVpp], [107.7], [40.64],
 [4.5 kHz], [1005 mVpp], [100], [40.00],
 [4 kHz], [1000 mVpp], [99.6], [39.97],
 [3.5 kHz], [994 mVpp], [98.9], [39.90],
 [3 kHz], [990 mVpp], [98.5], [39.87],
 [2.5 kHz], [980 mVpp], [97.5], [39.78],
 [2 kHz], [960 mVpp], [95.5], [39.60],
 [1.5 kHz], [928 mVpp], [92.3], [39.30],
 [1 kHz], [874 mVpp], [86.6], [38.75],
 [900 Hz], [859 mVpp], [85.5], [38.64],
 [800 Hz], [825 mVpp], [82.1], [38.29],
 [700 Hz], [789 mVpp], [78.5], [37.90],
 [600 Hz], [718 mVpp], [71.4], [37.07],
 [500 Hz], [588 mVpp], [58.5], [35.34],
 [400 Hz], [423 mVpp], [42.1], [32.49],
 [300 Hz], [241 mVpp], [23.9], [27.57],
 [200 Hz], [106 mVpp], [10.5], [20.42],
 [100 Hz], [31 mVpp], [3.1], [9.83],
), caption: [Bench low-frequency sweep for the Bode grid on manual page 11. Decibel values are calculated from the recorded gains.]) <tab-bench-low>

Using the manual's 5 kHz reference, $abs(A_m) = 107.7$, the threshold is 76.16 V/V (37.63 dB). It lies between 600 Hz (71.4 V/V) and 700 Hz (78.5 V/V). Interpolating gain in dB against log frequency gives $f_L approx 666$ Hz. Using the separate 50 kHz reference of 101.5 instead gives a threshold of 71.77 V/V and $f_L approx 605$ Hz. This reference choice changes the result appreciably.

*Marked lower cutoff.* The notes identify 540 Hz and 0.682 V as the 3-dB point. The bench photograph (@fig-scope-540) confirms 540 Hz on both channels, 10.11 mVpp input and 682 mVpp output. The measured ratio is $682/10.11 = 67.46$ V/V (36.58 dB), which is 4.06 dB below 107.7 and 3.55 dB below 101.5. Thus the photograph verifies the recorded operating frequency and amplitudes, but does not establish 540 Hz as the 3-dB cutoff for either reference. The generator is set to a 10.00 mVpp sine in High Z mode, and the oscilloscope shows averaging over eight acquisitions.

*Simulation.* The LTspice threshold is 89.69 V/V (39.055 dB), and the saved log gives $f_L = 623.87$ Hz. The 666 Hz bench interpolation is about 7% higher, whereas the 605 Hz alternative is about 3% lower.

The bypass capacitor is the main cause of this roll-off. A simple estimate, neglecting $r_o$ and taking an ideal source, gives
$ R_"seen,E" approx R_E || (r_pi / (beta + 1)) = 24.5 "Ω", quad f_"E" approx 1/(2 pi R_"seen,E" C_E) = 650 "Hz". $
This estimate is close to the LTspice lower cutoff. It is not an exact multi-capacitor transfer-function solution. The Multisim lower cutoff, about 970 Hz, is 55% higher than LTspice and remains a separate pre-lab result.

== High-frequency response (procedure steps 1 and 2)
*50 kHz comparison.* The separate measurement gives $abs(A_"50 kHz") = 101.5$ V/V, close to but below the 5 kHz value of 107.7 V/V. This is consistent with both frequencies lying near mid-band, although the readings are not identical.

*High-frequency sweep.* The second sweep explicitly uses 20 mVpp input. @tab-bench-high lists its output readings and the gains calculated assuming that input remains constant. At 5–35 kHz the output is 1.83 Vpp, giving 91.5 V/V. The handwritten 85 V/V entry beside the first row does not equal $1.83 "V" \/ 20 "mV"$; a gain of 85 would require about 21.5 mVpp input. No per-frequency input readings are available to choose between these values.

#figure(grid(columns: (1fr, 1fr), gutter: 14pt,
rtable(columns: (1fr, 1fr, 1fr), header: ([Freq. (kHz)], [Output (Vpp)], [Gain (V/V)]),
 [5], [1.83], [91.5],
 [15], [1.83], [91.5],
 [25], [1.83], [91.5],
 [35], [1.83], [91.5],
 [45], [1.82], [91.0],
 [55], [1.82], [91.0],
 [65], [1.81], [90.5],
 [75], [1.79], [89.5],
 [85], [1.79], [89.5],
 [95], [1.78], [89.0],
 [105], [1.77], [88.5],
 [115], [1.75], [87.5],
 [125], [1.74], [87.0],
 [135], [1.73], [86.5],
 [145], [1.71], [85.5],
 [155], [1.71], [85.5],
 [165], [1.69], [84.5],
),
rtable(columns: (1fr, 1fr, 1fr), header: ([Freq. (kHz)], [Output (Vpp)], [Gain (V/V)]),
 [175], [1.67], [83.5],
 [185], [1.65], [82.5],
 [195], [1.65], [82.5],
 [205], [1.63], [81.5],
 [215], [1.59], [79.5],
 [225], [1.57], [78.5],
 [235], [1.55], [77.5],
 [245], [1.53], [76.5],
 [255], [1.51], [75.5],
 [265], [1.49], [74.5],
 [275], [1.47], [73.5],
 [285], [1.47], [73.5],
 [295], [1.43], [71.5],
 [305], [1.43], [71.5],
 [315], [1.39], [69.5],
 [325], [1.37], [68.5],
)
), caption: [Bench high-frequency sweep, with frequency units continued as kHz from the handwritten heading. Gains are calculated using the stated 20 mVpp input.]) <tab-bench-high>

*Marked upper cutoff.* The circled row is 295 kHz, 1.43 Vpp, annotated 71.76 V/V. The output divided by 20 mVpp gives 71.5 V/V, close to that annotation. Also, $101.5/sqrt(2) = 71.77$ V/V, so the marked 295 kHz cutoff uses the earlier 50 kHz gain as its reference. However, the high-frequency sweep's own plateau is 91.5 V/V. Relative to that plateau, the 295 kHz point is only 2.14 dB down. Its same-run 3-dB output threshold is $1.83/sqrt(2) = 1.294$ Vpp, which is not reached even at 325 kHz (1.37 Vpp). Under the constant-input assumption, the sweep therefore establishes only $f_H > 325$ kHz, not a measured same-run cutoff.

The manual's 0.5-gain stopping condition is a −6.02 dB point. The final reading is $1.37/1.83 = 0.749$ of this run's plateau, so the recorded sweep stops before that condition as well. The marked 295 kHz value is reported with its reference qualification; it is not combined with the lower-cutoff estimate to claim a verified bandwidth.

#figure(image("images/bench_bode.svg", width: 100%), caption: [Bench Bode plots. Left: recorded low-frequency gains and the 3-dB threshold from 107.7 V/V. Right: gains calculated from the 20 mVpp high-frequency sweep, with its own 91.5 V/V reference. The square marks the annotated 295 kHz point.])

*Simulation.* The saved LTspice response is essentially at its maximum at 50 kHz and has $f_H = 19.5268$ MHz. Its source-to-output bandwidth is approximately 19.53 MHz. Both simulations predict upper cutoffs above the highest recorded bench frequency, so an exact experimental bandwidth comparison cannot be made from this sweep.

#figure(image("images/bode_comparison.svg", width: 100%), caption: [Gain from the saved LTspice AC data and from the Multisim pre-lab poles and zeros, normalized to the reported Multisim mid-band level of 42.1 dB. The dotted line is the LTspice 3-dB threshold. These curves are simulations, not measured bench sweeps.]) <fig-bode>

= Comparison of results
#figure(rtable(
 columns: (1.3fr, 1.2fr, 1.1fr, 1.1fr, 1fr),
 header: ([Quantity], [Hand analysis], [Multisim pre-lab], [LTspice], [Bench]),
 [Mid-band magnitude], [127 V/V], [124.7 at 5 kHz], [126.84 maximum], [107.7 at 5 kHz],
 [Mid-band level], [42.1 dB], [41.9 dB at 5 kHz], [42.065 dB], [40.64 dB at 5 kHz],
 [Lower cutoff $f_L$], [≈ 650 Hz (estimate)], [≈ 970 Hz], [623.87 Hz], [≈ 666 Hz (5 kHz ref.)],
 [Upper cutoff $f_H$], [Source dependent], [≈ 3.28 MHz], [19.53 MHz], [> 325 kHz (same run)],
 [Bandwidth], [—], [≈ 3.28 MHz], [≈ 19.53 MHz], [not recorded],
), caption: [Comparison of analysis and simulations. Multisim cutoffs are reconstructed from its pre-lab pole-zero result; LTspice cutoffs are from its AC measurement log. The bench upper bound assumes a constant 20 mVpp input; 540 Hz and 295 kHz are the separately marked, reference-dependent results.])

= Discussion
- *Gain comparison.* Theory and the simulations agree within about 2%. The bench gain of 107.7 is 15.2% below theory, and the separate 50 kHz gain of 101.5 is 20.1% below theory. The 20 mVpp sweep gives 91.5 V/V from its plateau output, so it needs its own gain reference.
- *Bandwidth comparison.* LTspice predicts an upper cutoff about six times the Multisim value. The models, capacitances and source impedances must be matched before assigning this difference to one cause. Neither simulated upper cutoff can be checked by a bench sweep that ends at 325 kHz.
- *Source and instrumentation.* The hand-analysis input resistance is about 2.51 kΩ, so a 50 Ω source causes about 2% mid-band attenuation. Probe and breadboard capacitance can affect the high-frequency response, while scope AC coupling can affect low-frequency readings. These effects cannot be quantified from the recorded amplitudes alone.
- *Reference consistency.* The marked 540 Hz and 295 kHz points do not use a verified common reference. The high-frequency record also labels the first-row gain as 85 V/V, whereas its stated voltage ratio gives 91.5. Repeating the sweep with simultaneous base and output readings would resolve the gain reference and establish the upper cutoff. Measured bias, transistor $beta$ and component values are still unavailable.

= Conclusion
The bench gain magnitude was 107.7 V/V at 5 kHz, 15.2% below the theoretical 127 V/V; the separate 50 kHz reading was 101.5 V/V. The low-frequency data give $f_L approx 666$ Hz using the 5 kHz reference, close to the LTspice result of 624 Hz. The notes mark 540 Hz and 295 kHz as cutoff points, but those marks do not form a verified pair with a consistent reference gain. For the high-frequency sweep's stated 20 mVpp input, the plateau gain is 91.5 V/V and the −3 dB level is not reached by 325 kHz. The measured roll-off is clear, while the upper cutoff and bandwidth require a longer sweep with the input measured at each point.

#pagebreak(weak: true)
#set heading(numbering: none)
= Appendix A: Bench notes
#figure(image("images/bench_low_frequency.png", height: 18cm), caption: [Original low-frequency notes, including the marked 540 Hz, 0.682 V point.])
#figure(image("images/bench_50khz.png", width: 74%), caption: [Separate 50 kHz measurement: 1.015 V output and gain 101.5 V/V.])
#pagebreak(weak: true)
#figure(image("images/bench_high_frequency.png", height: 17cm), caption: [Original high-frequency sweep. The circled row is 295 kHz and 1.43 V, annotated 71.76 V/V.])
#figure(image("images/bench_high_input.png", width: 46%), caption: [Recorded input setting for the high-frequency sweep: 20 mVpp.])
#pagebreak(weak: true)
= Bench photograph at 540 Hz
The photograph documents the low-frequency measurement used for the Bode grid on manual page 11 (procedure step 4 on page 10). CH1 is the input and CH2 is the output. The displayed readings are transcribed below so they remain legible at report scale.

#figure(image("images/bench_scope_540hz.png", width: 100%), caption: [Bench capture at 540 Hz. The generator is set to a 10.00 mVpp sine in High Z mode; the scope measures 10.11 mVpp on CH1 and 682 mVpp on CH2.]) <fig-scope-540>

#figure(rtable(
 columns: (1.5fr, 1fr),
 header: ([Quantity], [Displayed or calculated value]),
 [Frequency, CH1 and CH2], [540 Hz],
 [Input, CH1], [10.11 mVpp],
 [Output, CH2], [682 mVpp],
 [Gain magnitude $abs(v_o/v_b)$], [67.46 V/V],
 [Gain in dB], [36.58 dB],
 [Drop from the 5 kHz gain of 107.7], [4.06 dB],
), caption: [Readings from the photograph and the resulting voltage gain.])

#pagebreak(weak: true)
= Appendix B: Pre-lab simulation records
#figure(image("images/prelab_p4_0.png", width: 67%), caption: [Multisim oscilloscope capture retained in the pre-lab. The recorded cursor amplitudes are 19.8 mVpp input and 2.47 Vpp output.])
#figure(image("images/prelab_p4_1.png", width: 80%), caption: [Multisim pole-zero analysis retained in the pre-lab.]) <fig-pz>

#pagebreak(weak: true)
= Appendix C: LTspice netlists
#set text(6.2pt)
#columns(2, gutter: 14pt)[
 *Common-emitter amplifier, AC analysis* (`sim/ce_amp_ac.cir`)
 #raw(read("sim/ce_amp_ac.cir"), block: true)
 #colbreak()
 *Common-emitter amplifier, transient analysis* (`sim/ce_amp_tran.cir`)
 #raw(read("sim/ce_amp_tran.cir"), block: true)
]
