// ELG3136 Electronics II, Lab 3 pre-lab
// Frequency response of a common-emitter BJT amplifier
// Compile with: typst compile prelab3.typ

// ===========================================================================
// Pole/zero values (Hz) used to draw the Bode plot (Task 8): MultiSim results
// converted from rad/s (f = |s| / 2 pi). Negative = left half-plane,
// positive = right half-plane, 0 = at the origin.
// Hand-analysis values, for comparison:
//   zeros (0, 0, -3.70, 3.57e9), poles (-3.38e-3, -2.06, -654, -19.8e6, -1.19e9)
#let bode-zeros = (0, 0, -3.066, 3.490e9)
#let bode-poles = (-3.379e-3, -2.511, -968.0, -3.290e6, -1.204e9)
#let am-db = 42.1 // |A_m| in dB
// ===========================================================================

#set document(title: "ELG3136 Lab 3 Pre-lab")
#set page(paper: "us-letter", margin: 2cm, numbering: "1 / 1")
#set text(font: "New Computer Modern", size: 10.5pt)
#set par(justify: true)
#show heading.where(level: 1): set text(size: 12pt)
#set table(stroke: 0.5pt + luma(140), inset: 5pt)
#show figure.caption: set text(size: 9pt)
#show figure.where(kind: table): set figure.caption(position: top)
#set heading(numbering: none)

// ----------------------------- math helpers --------------------------------
#let p10(x) = calc.exp(x * calc.ln(10))
#let lg(x) = calc.log(x, base: 10)

#let eng(x) = {
  let pre = ((1e9, "G"), (1e6, "M"), (1e3, "k"), (1.0, ""), (1e-3, "m"))
  for (s, p) in pre {
    if x >= s * 0.9995 {
      let v = x / s
      let d = if v >= 99.95 { 0 } else if v >= 9.995 { 1 } else { 2 }
      let r = calc.round(v, digits: d)
      return (if d == 0 { str(int(r)) } else { str(r) }) + " " + p + "Hz"
    }
  }
  str(x) + " Hz"
}

// ------------------------------ Bode helper --------------------------------
// Returns (plot: content, fL: string, fH: string). Magnitude only.
#let bode(zeros, poles, am-db, fmin: 0.1, fmax: 1e11, ymin: -60, ymax: 60, w: 15cm, h: 5.5cm) = {
  let d0 = int(calc.round(lg(fmin)))
  let d1 = int(calc.round(lg(fmax)))
  let X(f) = (lg(f) - d0) / (d1 - d0) * w
  let Y(v) = (ymax - calc.clamp(v, ymin, ymax)) / (ymax - ymin) * h
  // log-magnitude (dB) up to a constant: exact and straight-line
  let G(f) = {
    let s = 0.0
    for z in zeros { s += if z == 0 { 20 * lg(f) } else { 10 * lg(f * f + z * z) } }
    for p in poles { s -= 10 * lg(f * f + p * p) }
    s
  }
  let Ga(f) = {
    let s = 0.0
    for z in zeros { s += 20 * lg(if z == 0 { f } else { calc.max(f, calc.abs(z)) }) }
    for p in poles { s -= 20 * lg(calc.max(f, calc.abs(p))) }
    s
  }
  // mid-band reference: centre of the widest gap between consecutive poles
  let ps = poles.map(calc.abs).sorted()
  let best = 0
  for i in range(ps.len() - 1) {
    if ps.at(i + 1) / ps.at(i) > ps.at(best + 1) / ps.at(best) { best = i }
  }
  let fmid = calc.sqrt(ps.at(best) * ps.at(best + 1))
  let g0 = G(fmid)
  let ga0 = Ga(fmid)
  let db(f) = am-db + G(f) - g0
  let dba(f) = am-db + Ga(f) - ga0
  // 3-dB frequencies by bisection on a log scale
  let cross(lo, hi, rising) = {
    let a = lg(lo)
    let b = lg(hi)
    for k in range(60) {
      let m = (a + b) / 2
      if (db(p10(m)) < am-db - 3) == rising { a = m } else { b = m }
    }
    p10((a + b) / 2)
  }
  let fL = cross(fmin, fmid, true)
  let fH = cross(fmid, fmax, false)

  let thin = 0.3pt + luma(225)
  let major = 0.5pt + luma(180)
  let canvas = box(width: w, height: h, {
    for d in range(d0, d1) {
      for m in range(2, 10) {
        let x = X(m * p10(d))
        place(top + left, line(start: (x, 0pt), end: (x, h), stroke: thin))
      }
    }
    for d in range(d0, d1 + 1) {
      let x = X(p10(d))
      place(top + left, line(start: (x, 0pt), end: (x, h), stroke: major))
      place(top + left, dx: x - 15pt, dy: h + 4pt,
        box(width: 30pt, align(center, text(7.5pt)[$10^(#d)$])))
    }
    for v in range(ymin, ymax + 1, step: 20) {
      place(top + left, line(start: (0pt, Y(v)), end: (w, Y(v)), stroke: major))
      place(top + left, dx: -32pt, dy: Y(v) - 4pt,
        box(width: 28pt, align(right, text(7.5pt)[#v])))
    }
    // pole (red, labels on top) and zero (blue, labels at bottom) markers
    let mark(f, col, lab, top-row) = {
      let x = X(f)
      place(top + left, line(start: (x, 0pt), end: (x, h),
        stroke: (paint: col, thickness: 0.7pt, dash: "dashed")))
      place(top + left, dx: x + 2pt, dy: if top-row { 2pt } else { h - 11pt },
        text(7.5pt, fill: col, lab))
    }
    for (i, p) in poles.enumerate() {
      let f = calc.abs(p)
      if f >= fmin and f <= fmax { mark(f, rgb("#c0392b"), $p_#(i + 1)$, true) }
    }
    for (i, z) in zeros.enumerate() {
      let f = calc.abs(z)
      if z != 0 and f >= fmin and f <= fmax { mark(f, rgb("#2471a3"), $z_#(i + 1)$, false) }
    }
    // straight-line asymptotes (dashed)
    let bp = ((fmin, fmax) + (zeros + poles).map(calc.abs).filter(f => f > fmin and f < fmax)).sorted()
    for i in range(bp.len() - 1) {
      place(top + left, line(
        start: (X(bp.at(i)), Y(dba(bp.at(i)))),
        end: (X(bp.at(i + 1)), Y(dba(bp.at(i + 1)))),
        stroke: (paint: luma(70), thickness: 0.9pt, dash: "dashed"),
      ))
    }
    // exact magnitude (solid)
    let n = 480
    let pts = range(n + 1).map(i => {
      let f = p10(d0 + (d1 - d0) * i / n)
      (X(f), Y(db(f)))
    })
    for i in range(n) {
      place(top + left, line(start: pts.at(i), end: pts.at(i + 1), stroke: 1.3pt + black))
    }
    // 3-dB points
    for f in (fL, fH) {
      place(top + left, dx: X(f) - 2.5pt, dy: Y(am-db - 3) - 2.5pt,
        circle(radius: 2.5pt, fill: white, stroke: 1pt + rgb("#c0392b")))
    }
    place(top + left, rect(width: w, height: h, stroke: 0.6pt))
    place(top + left, dx: -32pt, dy: -14pt, text(8pt)[$|A_v|$ (dB)])
    place(top + left, dy: h + 17pt, box(width: w, align(center, text(8pt)[Frequency (Hz)])))
  })
  (plot: pad(left: 34pt, top: 14pt, bottom: 28pt, canvas), fL: eng(fL), fH: eng(fH))
}


// =============================== DOCUMENT ==================================

#let ans(body) = align(center, block(stroke: 0.7pt + luma(80), inset: (x: 10pt, y: 6pt), radius: 2pt, align(left, body)))

#align(center)[
  #text(15pt, weight: "bold")[Lab 3: Frequency Response of a Common-Emitter BJT Amplifier] \
  #text(11pt)[Pre-lab]
]

*Given.* $V_"CC" = 15$ V, $R_1 = 22$ kΩ, $R_2 = 12$ kΩ, $R_C = 3.3$ kΩ, $R_E = 4.3$ kΩ, $R_L = 4.7$ MΩ, $C_1 = C_2 = C_E = 10$ μF. 2N3904 (NPN): $beta = 150$, $V_A approx 74$ V, $V_"BE" = 0.7$ V, $V_T = 26$ mV.

= DC analysis
At DC the capacitors are open. Replace the divider by its Thevenin equivalent (@fig-dc):
$ V_"Th" = 15 dot.op 12/34 = 5.29 "V", quad R_B = 12 "k" || 22 "k" = 7.76 "kΩ" $

#figure(image("hw_dc.png", width: 34%), caption: [Bias divider and its Thevenin equivalent; ① is the KVL loop.]) <fig-dc>

KVL around loop ①, then solve for $I_B$:
$ V_"Th" = I_B R_B + V_"BE" + (beta + 1) I_B R_E quad => quad I_B = (V_"Th" - V_"BE")/(R_B + (beta + 1) R_E) = 6.99 "μA" $
$ I_C = beta I_B = 1.05 "mA", quad I_E = (beta + 1) I_B = 1.06 "mA" $
$ V_E = I_E R_E = 4.54 "V", quad V_B = V_E + V_"BE" = 5.24 "V", quad V_C = V_"CC" - I_C R_C = 11.54 "V" $
$V_"CE" = 7.0$ V and $V_"CB" = 6.3$ V $> 0$, so the transistor is in forward active. Small-signal parameters:
$ g_m = I_C/V_T = 40.3 "mS", quad r_pi = beta/g_m = 3.72 "kΩ", quad r_o = V_A/I_C = 70.6 "kΩ" $

= Task 1: Circuit with parasitic capacitances
$C_pi$ is the capacitance between base and emitter and $C_mu$ the capacitance between base and collector (@fig-par).

#figure(image("hw_circuit.png", width: 62%), caption: [Common-emitter amplifier with $C_pi$ (B-E) and $C_mu$ (B-C) added.]) <fig-par>

Their values follow from the 2N3904 SPICE model parameters: $C_"jc0" = 3.64$ pF, $phi_c = 0.75$ V, $m_c = 0.31$, $tau_F = 301$ ps and a forward-biased $C_"je" approx 6.4$ pF.
$ C_mu = C_"jc0"/(1 + V_"CB"\/phi_c)^(m_c) = 1.8 "pF", quad C_pi = g_m tau_F + C_"je" = 19 "pF" $
Check: $f_T = g_m \/ (2 pi (C_pi + C_mu)) = 310$ MHz, close to the 300 MHz in the datasheet.

= Task 2: Gain as $f -> 0$
All capacitors are open (@fig-f0), so no AC signal reaches the base.

#figure(image("hw_f0.png", width: 40%), caption: [The amplifier as $f -> 0$: every capacitor is open.]) <fig-f0>

#ans[$A_v -> 0$ as $f -> 0$. The two zeros at $s = 0$ (from $C_1$ and $C_2$) give a +40 dB/dec slope.]

= Task 3: Gain as $f -> oo$
All capacitors, including $C_pi$ and $C_mu$, are shorted (@fig-finf).

#figure(image("hw_finf.png", width: 62%), caption: [Small-signal circuit as $f -> oo$.]) <fig-finf>

- The $C_pi$ short is in parallel with $r_pi$, so $v_pi = 0$ and $g_m v_pi = 0$.
- The $C_mu$ short ties the output node to the base, which the $C_pi$ short holds at ground, so $v_"out" = 0$.

#ans[$A_v -> 0$ as $f -> oo$.]

= Task 4: Mid-band gain
$C_1$, $C_2$, $C_E$ are shorted and only the parasitics $C_pi$, $C_mu$ are open (@fig-mid).

#figure(image("hw_mid.png", width: 66%), caption: [Mid-band small-signal circuit.]) <fig-mid>

$ v_pi = v_"in", quad r_o || R_C || R_L = 3.15 "kΩ", quad v_"out" = -g_m v_pi (R_C || R_L || r_o) $
$ A_m = v_"out"/v_"in" = -g_m (R_C || R_L || r_o) = -(40.3 "mS")(3.15 "kΩ") = -127 $

#ans[$A_m = -127$, $20 log_10 127 = 42.1$ dB ($-133$ if $r_o$ is neglected).]

#figure(
  table(
    columns: (1fr, 1fr),
    align: center,
    table.header([*Theoretical gain*], [*Measured gain $A_m$*]),
    [$-127$ (42.1 dB)], [],
  ),
  caption: [Mid-band voltage gain (manual Table 2).],
)

= Tasks 5 to 7: MultiSim
#figure(image("multisim_circuit.png", width: 66%),
  caption: [Circuit built in MultiSim (Task 5), with net names shown.]) <fig-ms>

#figure(image("multisim_scope.png", width: 58%),
  caption: [Oscilloscope at 5 kHz: channel A (yellow) is $v_"in"$ at the base, channel B (green) is $v_"out"$. The cursors give 19.8 mVpp in and 2.47 Vpp out, so $|A_v| approx 125$, inverted, close to the theoretical $-127$.]) <fig-scope>

Pole-zero analysis (Task 6): Simulate > Analyses and Simulation > Pole Zero, gain analysis from net 1 (generator side of $C_1$) to net out, both referenced to ground.

#figure(image("multisim_pz.png", width: 66%),
  caption: [MultiSim pole-zero result ($s$ in rad/s).]) <fig-pz>

#figure(
  table(
    columns: (auto, 1fr, auto, auto),
    align: (center, left, right, right),
    table.header([], [*Origin*], [*$s$ (rad/s)*], [*$f = |s| \/ 2 pi$*]),
    [$z_1, z_2$], [$C_1$, $C_2$ block DC], [$0$], [0 Hz],
    [$z_3$], [$C_E$ with $R_E$], [$-19.3$], [3.07 Hz],
    [$z_4$], [$C_mu$ feedforward (right half-plane)], [$+2.19 times 10^10$], [3.49 GHz],
    [$p_1$], [$C_2$ with $R_L$], [$-2.12 times 10^(-2)$], [3.38 mHz],
    [$p_2$], [$C_1$], [$-15.8$], [2.51 Hz],
    [$p_3$], [$C_E$ (dominant low-frequency pole)], [$-6.08 times 10^3$], [968 Hz],
    [$p_4$], [Miller $C_mu$ and output node (dominant high)], [$-2.07 times 10^7$], [3.29 MHz],
    [$p_5$], [Non-dominant high-frequency pole], [$-7.57 times 10^9$], [1.20 GHz],
  ),
  caption: [Poles and zeros of $A_v (s) = V_"out" (s) \/ V_"in" (s)$ from MultiSim (Task 7). MultiSim also listed poles near $plus.minus 9 times 10^20$ rad/s and a zero at $-1.4 times 10^14$ rad/s; these are numerical artifacts and are left out.],
) <tab-pz>

= Task 8: Bode plot
#let bd = bode(bode-zeros, bode-poles, am-db, h: 6cm)
From @tab-pz, the straight-line slopes are: +20 dB/dec up to $p_2$ (2.51 Hz), flat to $z_3$ (3.07 Hz), +20 dB/dec to $p_3$ (968 Hz), flat at 42.1 dB to $p_4$ (3.29 MHz), then $-20$ dB/dec, $-40$ dB/dec after $p_5$ (1.20 GHz) and $-20$ dB/dec after $z_4$ (3.49 GHz).

#figure(
  bd.plot,
  caption: [Voltage-gain magnitude from the MultiSim poles and zeros: exact (solid) and straight-line asymptotes (dashed). Red and blue dashed lines mark poles and zeros ($p_1$ = 3.4 mHz is off scale); circles mark the 3-dB points.],
) <fig-bode>
#ans[$f_L approx$ #(bd.fL), #h(1em) $f_H approx$ #(bd.fH)]
