#set page(paper: "us-letter", margin: 2cm)
#set text(size: 11pt)
#set par(justify: true)
#show raw.where(block: true): block.with(fill: luma(245), inset: 8pt, radius: 3pt, width: 100%)

= BJT Current Mirror Pre-Lab
This is from Marcel's team. But, as we said to you, we don't currently have a group for the class and couldn't submit it.

Circuit: top of $R_1 = 6.8 thin k Omega$ and $R_x$ at ground (0 V), both emitters at $-10$ V. $Q_1$ is diode-connected, $Q_2$ copies its current.

Assumptions: $V_"BE" approx 0.7$ V, $V_"CE,sat" = 0.2$ V, matched transistors.

== Task 1: Bounds on $R_x$

=== Reference current
Loop through $R_1$ and $Q_1$:

$ i_"ref" = (0 - V_"BE" - (-10)) / (6.8 thin k Omega) = 9.3 / 6800 approx 1.37 "mA" $

=== Copied current
Accounting for base currents:

$ i_"copy" = i_"ref" beta / (beta + 2) approx i_"ref" quad (beta >> 1) $

=== Active-region condition for $Q_2$
$V_C = -i_"copy" R_x$ and $V_E = -10$ V, so

$ V_"CE2" = 10 - i_"copy" R_x >= V_"CE,sat" = 0.2 quad => quad R_x <= 9.8 / i_"copy" $

=== Result

#align(center, box(stroke: 0.6pt, inset: 8pt,
  $0 <= R_x lt.tilde 9.8 / (1.37 "mA") approx 7.2 thin k Omega$))

- Lower bound: $R_x = 0$ gives $V_"CE2" = 10$ V, still active (well below $V_"CEO"$).
- With $beta = 100$: $i_"copy" approx 1.34$ mA, so $R_(x,max) approx 7.3 thin k Omega$.
- Above $R_(x,max)$, $Q_2$ saturates and $i_"copy" approx 9.8 \/ R_x$.

== Task 2: Multisim Validation

=== a) $i_"ref"$
Hand calculation: *1.37 mA*. Multisim reads *1.38 mA*, which implies $V_"BE" approx 10 - 1.38 "m" times 6.8 "k" approx 0.62$ V for the 2N3394 model. Good agreement.

#block(fill: rgb("#eef4fb"), stroke: (left: 3pt + rgb("#4a7fc1")), inset: 10pt, width: 100%)[
  *Note: why $i_"copy" = 1.52$ mA with $R_x = 1 thin k Omega$* \
  $V_"CE1" approx 0.62$ V but $V_"CE2" approx 8.5$ V. The Early effect makes $Q_2$ conduct about 10% more. This is what step b) removes.
]

=== b) Remove the Early effect
For *both* Q1 and Q2 (keep them matched):

+ Double-click transistor > *Value* tab > *Edit model*.
+ Set `VAF = 1e6` (Early voltage) and `BF = 1e6` ($beta$).
+ Click *Change part model*.

Expected: $i_"copy" approx i_"ref" approx 1.38$ mA.

Result ($R_x = 1 thin k Omega$, emitter supply $-10$ V): $i_"ref" = 1.38$ mA, $i_"copy" = 1.359$ mA. The remaining 1.5% gap is base-current error ($beta$ finite).

#figure(image("multisim_mirror_circuit.png", width: 80%), caption: [Multisim current mirror circuit])

=== c) Parameter sweep of $R_x$
+ *Simulate > Analyses and simulation > Parameter Sweep*.
+ Device type: *Resistor*, Name: *Rx*, Parameter: *resistance*.
+ Sweep: linear, 0 to 10 kΩ (e.g. 100 points).
+ Analysis to sweep: *DC Operating Point*.
+ Output: `I(Rx)` (or $V_C$).

Expected: $i_"copy"$ flat at about 1.38 mA up to about 7.1 kΩ, then dropping as $approx 9.8 \/ R_x$ (saturation). The knee should match Task 1.

Result: $i_"copy"$ stays constant at about 1.36 mA up to about 7 kΩ, then its magnitude falls as $Q_2$ saturates. This matches the Task 1 bound ($R_x lt.tilde 7.2 thin k Omega$). The negative sign is only the reference direction of `I(RX)`.

#figure(image("multisim_rx_sweep.png", width: 80%), caption: [Parameter sweep of $R_x$])

== LTspice Version

Recreation of the Multisim circuit: R1 = 6.8k, Rx = 1k, Q1 diode-connected, V1 puts both emitters at -10 V. The 2N3394 model is copied from Multisim (VAF = 2e6), included inline so the file runs on its own.

=== Netlist
Save as `current_mirror.cir`, then *File > Open* in LTspice and press *Run*.

```spice
* BJT current mirror recreation of Multisim circuit for fun ;)
R1 0 B 6.8k
Rx 0 VC {Rx}
Q1 B B VE QN
Q2 VC B VE QN
V1 VE 0 -10
.param Rx=1k
.model QN NPN(IS=6.101e-14 BF=121.3 NF=1 VAF=2e6 IKF=0.09779 ISE=1.222e-13 NE=1.305 BR=0.2359 NR=1)
.op
.step param Rx 1k 10k 100
* Log list: Icopy and VCE2 at chosen Rx values
.meas OP Iref FIND I(R1) AT=1k
.meas OP Icopy_1k FIND I(Rx) AT=1k
.meas OP Icopy_4k FIND I(Rx) AT=4k
.meas OP Icopy_7k FIND I(Rx) AT=7k
.meas OP Icopy_7k2 FIND I(Rx) AT=7.2k
.meas OP Icopy_8k FIND I(Rx) AT=8k
.meas OP Icopy_10k FIND I(Rx) AT=10k
.meas OP VCE2_7k2 FIND V(VC)-V(VE) AT=7.2k
.meas OP VCE2_8k FIND V(VC)-V(VE) AT=8k
* Knee: Rx where Q2 reaches VCE,sat = 0.2 V
.meas OP Rx_knee WHEN V(VC)-V(VE)=0.2
.end
```

Node map: `B` = Q1 collector + both bases, `VC` = Q2 collector, `VE` = both emitters.

```
Files loaded:
C:\Desktop\MyNotes\uOttawa\Year_4\current_mirror.cir

iref: I(R1) =0.00137996987905 at 1000
icopy_1k: I(Rx) =0.00133690459188 at 1000
icopy_4k: I(Rx) =0.00133690191433 at 4000
icopy_7k: I(Rx) =0.00133689923678 at 7000
icopy_7k2: I(Rx) =0.00133689248469 at 7200
icopy_8k: I(Rx) =0.00123453885317 at 8000
icopy_10k: I(Rx) =0.000991007196717 at 10000
vce2_7k2: V(VC)-V(VE) =0.374374389648 at 7200
vce2_8k: V(VC)-V(VE) =0.123688697815 at 8000
rx_knee: V(VC)-V(VE)=0.2 AT 7374.32908044
```

- *Log:* open *View > SPICE Error Log* (Ctrl+L). Scroll past the "Direct Newton" lines to the `Iref`, `Icopy` and `VCE2` tables, one row per Rx step. The knee is where `VCE2` reaches about 0.2 V.
- To see the Early effect (2a), set `VAF=74` and rerun: the flat region now slopes.
- To remove base-current error, set `BF=1e6`: the flat level rises to about 1.38 mA.
