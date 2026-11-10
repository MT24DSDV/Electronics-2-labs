// ELG3136 Electronics II, Lab 3 pre-lab
// Frequency response of a common-emitter BJT amplifier
// Compile with: typst compile prelab3.typ

// ===========================================================================
// Pole/zero values (Hz) used to draw the Bode plot (Task 8).
// Negative = left half-plane, positive = right half-plane, 0 = at the origin.
// To redraw from MultiSim, replace these with your MultiSim values
// (if MultiSim reports s in rad/s, divide by 2*pi first).
#let bode-zeros = (0, 0, -3.70, 3.57e9)
#let bode-poles = (-3.38e-3, -2.06, -654, -19.8e6, -1.19e9)
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

// --------------------------- schematic helpers -----------------------------
#let u = 0.6cm
#let P(x, y) = (x * u, y * u)
#let pc = rgb("#c0392b") // parasitic elements

#let wire(..pts, col: black, dash: none) = {
  let p = pts.pos()
  for i in range(p.len() - 1) {
    place(top + left, line(
      start: P(..p.at(i)),
      end: P(..p.at(i + 1)),
      stroke: (paint: col, thickness: 0.8pt, dash: dash),
    ))
  }
}

#let jdot(x, y) = place(top + left, dx: x * u - 2pt, dy: y * u - 2pt,
  circle(radius: 2pt, fill: black, stroke: none))

#let term(x, y) = place(top + left, dx: x * u - 2.5pt, dy: y * u - 2.5pt,
  circle(radius: 2.5pt, fill: white, stroke: 0.8pt))

#let lbl(x, y, body, anchor: "c", size: 8.5pt) = context {
  let al = if anchor == "l" { left } else if anchor == "r" { right } else { center }
  let b = box({
    set align(al)
    set par(leading: 0.35em, justify: false)
    set text(size: size)
    body
  })
  let m = measure(b)
  let ox = if anchor == "l" { 0pt } else if anchor == "r" { -m.width } else { -m.width / 2 }
  place(top + left, dx: x * u + ox, dy: y * u - m.height / 2, b)
}

#let res-v(x, y1, y2, label: none, side: "l", at: none) = {
  let ym = if at == none { (y1 + y2) / 2 } else { at }
  let L = 1.6
  let a = ym - L / 2
  let b = ym + L / 2
  wire((x, y1), (x, a))
  wire((x, b), (x, y2))
  let pts = ((x, a),)
  for i in range(6) {
    let xx = if calc.rem(i, 2) == 0 { x + 0.28 } else { x - 0.28 }
    pts.push((xx, a + (i + 0.5) * L / 6))
  }
  pts.push((x, b))
  wire(..pts)
  if label != none {
    if side == "l" { lbl(x - 0.5, ym, label, anchor: "r") } else { lbl(x + 0.5, ym, label, anchor: "l") }
  }
}

#let plate(x1, y1, x2, y2, col) = place(top + left,
  line(start: P(x1, y1), end: P(x2, y2), stroke: (paint: col, thickness: 1.5pt)))

#let cap-v(x, y1, y2, label: none, side: "r", col: black, dash: none) = {
  let ym = (y1 + y2) / 2
  let g = 0.13
  let w = 0.42
  wire((x, y1), (x, ym - g), col: col, dash: dash)
  wire((x, ym + g), (x, y2), col: col, dash: dash)
  plate(x - w, ym - g, x + w, ym - g, col)
  plate(x - w, ym + g, x + w, ym + g, col)
  if label != none {
    if side == "l" { lbl(x - 0.6, ym, label, anchor: "r") } else { lbl(x + 0.6, ym, label, anchor: "l") }
  }
}

#let cap-h(x1, x2, y, label: none) = {
  let xm = (x1 + x2) / 2
  let g = 0.13
  let w = 0.42
  wire((x1, y), (xm - g, y))
  wire((xm + g, y), (x2, y))
  plate(xm - g, y - w, xm - g, y + w, black)
  plate(xm + g, y - w, xm + g, y + w, black)
  if label != none { lbl(xm, y - 0.85, label) }
}

#let gnd(x, y) = {
  wire((x, y), (x, y + 0.4))
  for (i, w) in ((0, 0.45), (1, 0.29), (2, 0.13)) {
    let yy = y + 0.4 + i * 0.17
    place(top + left, line(start: P(x - w, yy), end: P(x + w, yy), stroke: 0.8pt))
  }
}

#let arrow-on(p, q, t: 0.8, len: 0.38, hw: 0.15) = {
  let (x1, y1) = p
  let (x2, y2) = q
  let L = calc.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
  let dx = (x2 - x1) / L
  let dy = (y2 - y1) / L
  let tx = x1 + t * (x2 - x1)
  let ty = y1 + t * (y2 - y1)
  let bx = tx - len * dx
  let by = ty - len * dy
  place(top + left, polygon(fill: black, stroke: none,
    P(tx, ty), P(bx - hw * dy, by + hw * dx), P(bx + hw * dy, by - hw * dx)))
}

// Figure 1: CE amplifier with C_pi and C_mu added
#let schematic = box(width: 16 * u, height: 13.3 * u, {
  // supply rail
  wire((5, 1), (9, 1))
  wire((7, 1), (7, 0.55))
  lbl(7, 0.2, [$V_"CC" = 15$ V])
  // bias divider
  res-v(5, 1, 6.5, label: [$R_1$ \ 22 kΩ])
  res-v(5, 6.5, 12, label: [$R_2$ \ 12 kΩ])
  // source and input coupling capacitor
  place(top + left, dx: 0.9 * u, dy: 8.65 * u, circle(radius: 0.6 * u, stroke: 0.8pt))
  lbl(1.5, 9.25, text(11pt)[∼])
  lbl(2.35, 8.5, [+])
  lbl(0.75, 9.25, [$v_"in"$], anchor: "r")
  wire((1.5, 8.65), (1.5, 6.5))
  wire((1.5, 9.85), (1.5, 12))
  cap-h(1.5, 5, 6.5, label: [$C_1$ 10 μF])
  // base lead and NPN transistor
  wire((5, 6.5), (8, 6.5))
  place(top + left, line(start: P(8, 5.7), end: P(8, 7.3), stroke: 2pt))
  wire((8, 6.1), (9, 5.3), (9, 4.5))
  wire((8, 6.9), (9, 7.7), (9, 8.5))
  arrow-on((8, 6.9), (9, 7.7))
  lbl(9.45, 6.5, [Q1 \ 2N3904], anchor: "l")
  // parasitic capacitances (internal to the BJT)
  cap-v(6.8, 4.5, 6.5, label: text(fill: pc)[$C_mu$], side: "l", col: pc, dash: "dashed")
  wire((6.8, 4.5), (9, 4.5), col: pc, dash: "dashed")
  cap-v(6, 6.5, 8.5, label: text(fill: pc)[$C_pi$], side: "r", col: pc, dash: "dashed")
  wire((6, 8.5), (9, 8.5), col: pc, dash: "dashed")
  // collector side and load
  res-v(9, 1, 4.5, label: [$R_C$ \ 3.3 kΩ], side: "r")
  cap-h(9, 14, 4.5, label: [$C_2$ 10 μF])
  res-v(14, 4.5, 12, label: [$R_L$ \ 4.7 MΩ], side: "l", at: 7.2)
  wire((14, 4.5), (15.2, 4.5))
  // emitter side
  res-v(9, 8.5, 12, label: [$R_E$ \ 4.3 kΩ], side: "r")
  wire((9, 8.5), (11.5, 8.5))
  cap-v(11.5, 8.5, 12, label: [$C_E$ \ 10 μF], side: "r")
  // ground rail and output terminals
  wire((1.5, 12), (15.2, 12))
  gnd(7.5, 12)
  term(15.2, 4.5)
  term(15.2, 12)
  lbl(15.2, 5.3, [+])
  lbl(15.2, 8.25, [$v_"out"$])
  lbl(15.2, 11.2, [−])
  for (x, y) in ((5, 6.5), (6, 6.5), (6.8, 6.5), (9, 4.5), (9, 8.5), (14, 4.5),
                 (5, 12), (7.5, 12), (9, 12), (11.5, 12), (14, 12), (7, 1)) { jdot(x, y) }
})

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

#align(center)[
  #text(15pt, weight: "bold")[ELG3136 Electronics II: Lab 3 Pre-lab] \
  #text(11pt)[Frequency Response of a Common-Emitter BJT Amplifier]
]

#table(
  columns: (1fr, 1fr, 1fr),
  rows: (auto, 18pt),
  table.header([*Last name*], [*First name*], [*Student ID*]),
  [], [], [],
  [], [], [],
  [], [], [],
)

*Values used.* $V_"CC" = 15$ V, $R_1 = 22$ kΩ, $R_2 = 12$ kΩ, $R_C = 3.3$ kΩ, $R_E = 4.3$ kΩ, $R_L = 4.7$ MΩ, $C_1 = C_2 = C_E = 10$ μF ($C_1$ input coupling, $C_2$ output coupling, $C_E$ emitter bypass; C2, C3 and C4 in the manual's Figure 2). 2N3904: $beta = 150$ (assumed; use your measured $beta$), $V_"BE" = 0.7$ V, $V_T = 26$ mV, $V_A approx 74$ V, $r_b approx 10$ Ω.

= Operating point
$ V_"Th" = 15 dot.op 12/(22 + 12) = 5.29 "V", quad R_B = R_1 || R_2 = 7.76 "kΩ" $
$ I_B = (V_"Th" - V_"BE")/(R_B + (beta + 1) R_E) = 6.99 "μA", quad I_C = beta I_B = 1.05 "mA" $
$ V_C = 11.54 "V", quad V_E = 4.54 "V", quad V_"CE" = 7.0 "V" quad ("forward active") $
$ g_m = I_C/V_T = 40.3 "mS", quad r_pi = beta/g_m = 3.72 "kΩ", quad r_o = V_A/I_C = 70.6 "kΩ", quad R'_L = R_C || R_L || r_o = 3.15 "kΩ" $
$I_C$ barely depends on $beta$ (1.04 mA for $beta = 100$), so the estimates below are robust to the $beta$ assumption.

= Task 1: Circuit with BJT parasitic capacitances
Figure 1 adds the transistor's internal capacitances (red, dashed): $C_pi$ between base and emitter (diffusion plus B-E junction capacitance) and $C_mu$ between base and collector (B-C junction capacitance). The collector-substrate capacitance $C_"CS"$ is negligible for a discrete 2N3904.

#figure(schematic, caption: [Common-emitter amplifier with the BJT parasitic capacitances $C_pi$ and $C_mu$ added.])

= Task 2: Gain as $f -> 0$
At DC, $C_1$, $C_2$ and $C_E$ are open circuits: $C_1$ blocks the signal from the base and $C_2$ blocks it from $R_L$, so $|A_v| -> 0$ ($-oo$ dB). Each coupling capacitor contributes a zero at $s = 0$, so below every pole the slope is +40 dB/dec. Going down from mid-band, $C_E$ opens first; with $C_1$ and $C_2$ still acting as shorts the emitter is unbypassed and
$ A_v = -(beta R'_L)/(r_pi + (beta + 1) R_E) = -0.72 approx -R'_L/R_E quad (-2.8 "dB"), $
after which $C_1$ (near 2 Hz) and $C_2$ (near 3 mHz) take the gain to zero.

= Task 3: Gain as $f -> oo$
At very high frequency $C_pi$ and $C_mu$ become short circuits. $C_pi$ shorts $v_pi$, so $g_m v_pi -> 0$, and $C_mu$ ties the collector to the internal base, which $C_pi$ and $C_E$ hold at AC ground. Hence $v_"out" -> 0$ and $|A_v| -> 0$. With two high-frequency poles and one right-half-plane zero, the final roll-off is $-20$ dB/dec.

= Task 4: Mid-band gain
Short $C_1$, $C_2$, $C_E$ and open $C_pi$, $C_mu$:
$ A_m = v_"out"/v_"in" = -g_m (R_C || R_L || r_o) = -(40.3 "mS")(3.15 "kΩ") approx -127 quad (42.1 "dB") $
Neglecting $r_o$ gives $-133$. With an ideal source (MultiSim), or with $v_"in"$ measured at the base (lab), the generator resistance does not enter. Section II of the manual quotes about $-50$; for this fully bypassed stage the small-signal model predicts about $-127$, so confirm the value in MultiSim.

#figure(
  table(
    columns: (1fr, 1fr),
    align: center,
    table.header([*Theoretical gain*], [*Measured gain $A_m$*]),
    [$-127$ (42.1 dB)], [],
  ),
  caption: [Mid-band voltage gain (manual Table 2).],
)

= Tasks 5 to 7: MultiSim model and pole-zero analysis
// Task 5: replace the rect below with  image("multisim.png", width: 100%)
// Task 6: Simulate > Analyses and Simulation > Pole Zero. Gain analysis
// (output voltage / input voltage): input nodes = source node and ground,
// output nodes = vout and ground; compute poles and zeros. If the function
// generator causes trouble, use an AC voltage source for this analysis.
#figure(
  rect(width: 100%, height: 3.5cm, stroke: (paint: luma(150), dash: "dashed"),
    align(center + horizon, text(fill: luma(120))[Insert MultiSim schematic screenshot here])),
  caption: [Circuit of the manual's Figure 2 built in MultiSim (Task 5).],
)

The hand estimates below assume an ideal source ($R_s = 0$), as in MultiSim, and are listed in @tab-pz for checking the MultiSim result (Task 7).

*Low frequency* ($C_pi$, $C_mu$ open). $C_1$ and $C_2$ each give a zero at $s = 0$. $C_1$ and $C_E$ interact through the base input impedance, so their poles are the roots of a second-order denominator (solved exactly for @tab-pz; single-capacitor estimates shown):
$ omega_(z 3) = 1/(R_E C_E), quad omega_(p 3) approx 1/(C_E [R_E || (r_pi + R_s || R_B) \/ (beta + 1)]), \
  omega_(p 2) approx 1/(C_1 [R_s + R_B || (r_pi + (beta + 1) R_E)]), quad omega_(p 1) = 1/(C_2 (R_C || r_o + R_L)) $

*High frequency* ($C_1$, $C_2$, $C_E$ shorted). At this bias the 2N3904 model gives $C_mu = (3.64 "pF") \/ (1 + 6.3\/0.75)^(0.31) approx 1.8$ pF and $C_pi = g_m tau_F + C_"je" approx 12.2 + 6.4 approx 19$ pF ($f_T approx 310$ MHz). With $R_X = (r_b + R_s || R_B) || r_pi approx 10$ Ω seen at the internal base:
$ A_v (s) = A_m (1 - s C_mu \/ g_m)/(1 + b_1 s + b_2 s^2) $
$ b_1 = R_X [C_pi + (1 + g_m R'_L) C_mu] + R'_L C_mu = 8.16 "ns", quad b_2 = R_X R'_L C_pi C_mu = 1.07 times 10^(-18) "s"^2 $
The roots give $f_(p 4) = 19.8$ MHz (close to $1\/(2 pi b_1)$) and $f_(p 5) = 1.19$ GHz; the right-half-plane zero is at $g_m\/(2 pi C_mu) = 3.57$ GHz.

#figure(
  table(
    columns: (auto, 1fr, auto, auto, auto),
    align: (center, left, right, right, center),
    table.header([], [*Origin*], [*$s$ (rad/s)*], [*$f$*], [*MultiSim $f$*]),
    [$z_1, z_2$], [$C_1$, $C_2$ block DC], [$0$], [0 Hz], [],
    [$z_3$], [$C_E$ with $R_E$: $1\/(R_E C_E)$], [$-23.3$], [3.70 Hz], [],
    [$z_4$], [$C_mu$ feedforward: $g_m\/C_mu$ (RHP)], [$+2.24 times 10^10$], [3.57 GHz], [],
    [$p_1$], [$C_2$ with $R_C || r_o + R_L$], [$-2.13 times 10^(-2)$], [3.38 mHz], [],
    [$p_2$], [$C_1$], [$-12.9$], [2.06 Hz], [],
    [$p_3$], [$C_E$ (dominant low-frequency pole)], [$-4.11 times 10^3$], [654 Hz], [],
    [$p_4$], [Miller $C_mu$ and output node (dominant high)], [$-1.25 times 10^8$], [19.8 MHz], [],
    [$p_5$], [Non-dominant high-frequency pole], [$-7.47 times 10^9$], [1.19 GHz], [],
  ),
  caption: [Poles and zeros of $A_v (s) = V_"out" (s) \/ V_"in" (s)$: hand estimates and MultiSim values.],
) <tab-pz>

*On the bench.* The generator's $R_s = 50$ Ω raises $R_X$ to about 59 Ω, lowering $f_(p 4)$ to about 8 MHz. Scope cable and probe capacitance $C_L$ at the collector then dominates: $f_H approx 1\/(2 pi R'_L C_L) approx 0.5$ MHz for $C_L approx 100$ pF, so expect a measured upper cutoff far below the MultiSim value. $f_L$ stays near 650 Hz.

= Task 8: Bode plot
#let bd = bode(bode-zeros, bode-poles, am-db)
Straight-line slopes: +20 dB/dec up to $p_2$ (2.06 Hz), flat to $z_3$ (3.70 Hz), +20 dB/dec to $p_3$ (654 Hz), flat at 42.1 dB to $p_4$ (19.8 MHz), then $-20$ dB/dec, $-40$ dB/dec after $p_5$ and $-20$ dB/dec after $z_4$.

#figure(
  bd.plot,
  caption: [Voltage-gain magnitude from @tab-pz: exact (solid) and straight-line asymptotes (dashed). Red and blue dashed lines mark poles and zeros ($p_1$ = 3.4 mHz is off scale); circles mark the 3-dB points, $f_L approx$ #(bd.fL) and $f_H approx$ #(bd.fH).],
)
