// SPDX-FileCopyrightText: Copyright (C) Nile Jocson <seiversiana@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#import "@preview/charged-ieee:0.1.4": ieee

#import "@preview/fletcher:0.5.8": diagram, node, edge
#import "@preview/unify:0.7.1": num, qty, qtyrange,

#show: ieee.with(
	title: "PWM Motor Controller",
	authors: (
		(
			name: "Nile Jocson",
			department: [Electrical and Electronics Engineering Institute],
			organization: [University of the Philippines Diliman],
			location: [Quezon City, Philippines],
			email: "nile.xavier.jocson@eee.upd.edu.ph"
		),
	),
	bibliography: bibliography("refs.yaml"),
	figure-supplement: [Fig.],
)

#set figure(placement: auto)

#set table(
	columns: (6em, auto),
	align: (left, right),
	inset: (x: 8pt, y: 4pt),
	stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
	fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },
)

#let vstable = table.with(
	columns: (6em, auto),
	align: (x, y) => if x == 0 { left } else { right },
	inset: (x: 8pt, y: 4pt),
	stroke: (x, y) => {
		if x == 0 {
			(right: 0.5pt)
		}
		if y <= 1 {
			(top: 0.5pt)
		}
	},
	fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },
)

#let dtable = table.with(
	columns: (6em, auto),
	align: (left, right),
	inset: (x: 8pt, y: 4pt),
	stroke: (x, y) => {
		if x == 1 {
			(right: 0.5pt)
		}
		if y <= 1 {
			(top: 0.5pt)
		}
	},
	fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },
)



= Introduction
The Git repository for this project is located at
https://github.com/seiversiana/motor-pwm. This includes the license, the Typst
files, the images and image sources, and the LTSpice files.



= Theory
== Specifications
We are tasked to create a PWM motor controller by cascading an astable
multivibrator, a monostable multivibrator, an emitter follower, and finally a
DC chopper circuit. Only BJTs may be used. @f:spec shows the input and output
specifications of the system.

$
	V_"CC" = #qty(6, "V") \
	f_"S" = #qty("5.5+-0.1", "kHz") \
	D_"S, max" = #qty("80+-5", "%") \
	D_"S, min" = #qty("50+-5", "%")
$ <f:spec>

The motor used will be a #qty(6, "V"), size 130, brushed DC motor. A flyback
diode is required. The monostable multivibrator duty cycle should be controlled
by a common potentiometer, and the duty cycle must fully vary along one full
turn.

The block diagram of the system is shown in @d:block.

#figure(
	diagram(
		node-stroke: 1pt,
		node((0, 0), [Astable Multivibrator]), edge("-|>"),
		node((0, 0.7), [Monostable Multivibrator]), edge("-|>"),
		node((0, 1.4), [Emitter Follower]), edge("-|>"),
		node((0, 2.1), [DC Chopper])
	),
	caption: [Block diagram of the PWM motor controller system.],
	placement: none
) <d:block>

== Astable Multivibrator <s:astable>
The circuit diagram of the astable multivibrator is shown in @i:astable.

#figure(
	image("assets/astable.png"),
	caption: [Circuit diagram of the astable multivibrator.],
) <i:astable>

In order to design the astable multivibrator stage, we first need to choose
a transistor. The 2N3904 is a general-purpose low-current switching transistor
that is perfect for our purposes. According to its datasheet @2n3904, we can
solve for its maximum frequency @f:2n3904freq:

$
	f_"max" = 1/(t_"d" + t_"r" + t_"s" + t_"f") = #qty(3.125, "MHz")
$ <f:2n3904freq>

Our needed frequency is easily within this limit. Now, since the astable
multivibrator cycles its transistors between cut-off and saturation, we need to
determine the currents and resistor values in order to let the transistors go
into saturation. From the datasheet @2n3904, we have $V_"CE, sat" = #qty(0.2, "V")$
and $V_"BE, sat" = #qtyrange(0.65, 0.85, "V")$ for current conditions
$I_"C" = #qty(10, "mA")$ and $I_"B" = #qty(1, "mA")$. Using this information, we
can solve for the needed resistor values. To simplify the calculations, let's
assume an average base saturation voltage $V_"BE, sat" = #qty(0.75, "V")$
instead.

In order to further simplify calculations and to reduce the number of unique
components, we can recognize that the duty cycle of this stage does not matter,
since only the rising edge of the output will be used to trigger the monostable
multivibrator. This is independent of duty cycle, and only requires that the
frequency be constant. Therefore we assume a duty cycle $D_"A" = #qty(50, "%")$
and set $R_"AB1" = R_"AB2" = R_"AB"$, $R_"AC1" = R_"AC2" = R_"AC"$, and
$C_"A1" = C_"A2" = C_"A"$. The calculation for the base and collector resistors
are shown in @f:abase and @f:acollector.

$
	V_"CC" - I_"AB" R_"AB" - V_"BE, sat" = 0 \
	R_"AB" = (V_"CC" - V_"BE, sat")/I_"AB" = #qty(5.25, "kO")
$ <f:abase>

$
	V_"CC" - I_"AC" R_"AC" - V_"CE, sat" = 0 \
	R_"AC" = (V_"CC" - V_"CE, sat")/I_"AC" = #qty(580, "O")
$ <f:acollector>

Now, we can solve for the needed capacitor based on our frequency specification
$f_"S"$ @astable. This is shown in @f:acap.

$
	f_"S" = 1/(2 R_"AB" C_"A" ln 2) \
	C_"A" = 1/(2 R_"AB" f_"S" ln 2) = #qty(24.98, "nF")
$ <f:acap>

== Monostable Multivibrator
The circuit diagram of the monostable multivibrator coupled to the astable
multivibrator is shown in @i:monostable.

#figure(
	image("assets/monostable.png"),
	caption: [
		Circuit diagram of the monostable multivibrator coupled to the
		astable multivibrator.
	]
) <i:monostable>

For the monostable multivibrator, we use the 2N3904 again for the same reasons
as in @s:astable. We can also use $R_"MC1" = R_"AC"$ and $R_"MB1" = R_"AB"$,
since the values needed to saturate the transistors stay the same. For this
stage, we want the duty cycle to vary throughout the range of $D_"S"$. This is
done by varing $R_"MB1"$. Note that $R_"MB1" = R_"AB"$ is the maximum value of
the resistor; going above this will not supply the base of $Q_"M2"$ with enough
current to sustain saturation with $I_"C" = #qty(10, "mA")$. Now, since the duty
cycle of this stage $D_"M"$ is directly proportional to $R_"MB1"$, we want
$R_"MB1, max" = R_"AB"$ to give us the duty cycle $D_"S, max" = #qty(80, "%")$.

We will need to recalculate $C_"M"$ because of this. This is shown in
@f:mcapd and @f:mcapv.

$
	T_"S, on" =& R_"MB1, max" dot C_"M" ln 2 \
	T_"S" D_"S, max" =& R_"MB1, max" dot C_"M" ln 2 \
	f_"S" =& D_"S, max"/(R_"MB1, max" dot C_"M" ln 2)
$ <f:mcapd>

$
	C_"M" = D_"S, max"/(R_"MB1, max" dot f_"S" ln 2) = #qty(39.97, "nF")
$ <f:mcapv>

Next, we need to solve for the minimum base resistance $R_"MB1, min"$. We can
derive this equation using @f:mcapv, as shown in @f:mminbase.

$
	R_"MB1, min" = D_"S, min"/(C_"M" f_"S" ln 2) = #qty(3.28, "kO")
$ <f:mminbase>

We have a resistance difference of $Delta R_"MB1" = #qty(1.97, "kO")$. In
order to vary $R_"MB1"$ throughout its minimum and maximum values, we can have
a resistor network as shown in @i:rmb1.

#figure(
	image("assets/rmb1.png"),
	caption: [Resistor network equivalent of $R_"MB1"$.]
) <i:rmb1>

Here, $R_"P"$ is the potentiometer resistance, where $R_"P, max" >> Delta R_"MB1"$,
and $R_"P, min" = #qty(0, "O")$. This makes it so that when $R_"P" = R_"P, min"$,
$R_"MB1" = R_"MB1, min"$, and when $R_"P" = R_"P, max"$,
$R_"MB1" approx R_"MB1, max"$. Let's use an $R_"P" = #qtyrange(0, 1, "MO")$, so
that there is minimal deviation between the original and maximum varied
$R_"MB1, max"$.

Next, we can solve for $R_"MB2"$. Note that the base current $I_"B"$ should be
#qty(1, "mA") for saturation, which means that the equivalent resistance must
allow for this. Fortunately, we've already calculated this value before in @f:abase.
Setting $R_"MC2" = R_"MC1"$ and solving for $R_"MB2"$:

$ R_"MB2" = R_"AB" - R_"MC2" = #qty(4.67, "kO") $

Finally, we need to solve for the values for the coupling. First, we need to
select the diode for $D_"T"$. The 1N4148 is a high-speed switching diode which
is perfect for this purpose. From its datasheet @1n4148, we can calculate
its maximum frequency  @f:1n4148freq:

$
	f_"max" = 1/t_"rr" = #qty(250, "MHz")
$ <f:1n4148freq>

Our needed frequency is way below this limit. Now, we want a sufficient current
at the base of $Q_"M1"$ so that the transistor will reliably discharge $C_"M"$ and
allow the cross-coupling to take over. Let's set $I_"C" = #qty(50, "mA")$ and
$I_"B" = #qty(5, "mA")$. This gives us a $V_"BE, sat" = #qty(0.95, "V")$
@2n3904. Note that the forward voltage of the 1N4148 at this current is
$V_"F" = #qty(0.65, "V")$ @1n4148. With this information, we can solve for
$I_"out, A"$ by doing KVL through $R_"AC2"$ and the base of $Q_"M1"$ @f:aouti:

$
	V_"CC" - I_"out, A" dot R_"AC2" - V_"F" - V_"BE, sat" = 0 \
	I_"out, A" = (V_"CC" - V_"F" - V_"BE, sat")/R_"AC2" = #qty(7.59, "mA")
$ <f:aouti>

We then do KCL on the node between $C_"T"$, $R_"T"$, and $D_"T"$ to get
$I_"T"$ @f:tcurrent:

$
	I_"T" = I_"out, A" - I_"B" = #qty(2.59, "mA")
$ <f:tcurrent>

We also know the voltage at this node @f:tvoltage:

$
	V_"T" = V_"F" + V_"BE, sat" = #qty(1.6, "V")
$ <f:tvoltage>

We can now solve for $R_"T"$ @f:tresistance:

$
	R_"T" = V_"T"/I_"T" = #qty(618.67, "O")
$ <f:tresistance>

Finally, in order to solve for $C_"T"$, we want a pulse width that is long enough
to start regeneration and short enough that the capacitor fully resets before
the next cycle. A common value for this pulse width is
$#qty(10, "%") dot T_"on, min"$. We can use $T_"pulse" = R_"T" C_"T"$ for this
as we have a bit of leeway because our desired pulse width is much less than
the period. We can then solve
for $C_"T"$, as shown in @f:tcapd and @f:tcapv.

$
	T_"pulse" =& R_"T" C_"T" \
	#qty(10, "%") dot T_"S, on" =& R_"T" C_"T" \
	#qty(10, "%") dot T_"S" D_"S, min" =& R_"T" C_"T" \
	f_"S" =& (#qty(10, "%") dot D_"S, min")/(R_"T" C_"T")
$ <f:tcapd>

$
	C_"T" = (#qty(10, "%") dot D_"S, min")/(R_"T" f_"S") = #qty(14.69, "nF")
$ <f:tcapv>

== Buffer and DC Chopper
The circuit diagram of the DC chopper coupled to the emitter follower and
the monostable multivibrator is shown in @i:chopper.

#figure(
	image("assets/chopper.png"),
	caption: [
		Circuit diagram of the DC chopper coupled to the emitter follower and
		the monostable multivibrator.
	]
) <i:chopper>

In order to analyze this final section, we first need to know the current that
the collector of $Q_"D"$ will be receiving. A common stall current for a #qty(6, "V")
size 130 brushed motor is around #qty(800, "mA"), which is the maximum
$I_"C"$ of $Q_"D"$. For this, we will need to use a power transistor. One such
transistor is the TIP31C, which can handle up to #qty(3, "A") of collector
current @tip31c. This is more than enough for our needs. In order to get our
collector current, we need to saturate the transistor by setting $beta = 10$ or
equivalently, $I_"B" = I_"C"/10 = #qty(80, "mA")$ @tip31c. We also have
$V_"BE, sat" = #qty(0.7, "V")$ and $V_"CE, sat" = #qty(0.25, "V")$ in these
conditions.

There is no way our monostable multivibrator will be able to supply this
current, so we use an emitter follower in between the two stages. This is
perfect as it has a high impedance input and a low impedance output, which
means that it can drive the DC chopper using the output signal from the
monostable multivibrator.

We won't be using the 2N3904 here as the collector current that we will need
is almost near its maximum rating of #qty(200, "mA"), which risks overheating. Instead, let's use the 2N4401, which is rated for collector currents of up to #qty(600, "mA")
@2n4401. Let's set the $I_"C"$ of $Q_"E"$ to be #qty(100, "mA"), so that we
have more than enough current at the emitter to drive the DC chopper. Note that
an emitter follower does not go into saturation; instead it sits inside
forward-active. From the datasheet @2n4401, the closest $beta$ for our $I_C$ is
$beta = 80$, with $V_"CE" = #qty(1, "V")$. Therefore, we will need a base
current $I_"B" = #qty(1.25, "mA")$ for the emitter follower.

Now, we solve for $I_"E"$, $R_"EE"$, and $R_"DB"$. Solving for $I_"E"$ @f:eemitter:

$
	I_"E" =& I_"B" + I_"C" \
		=& I_"C"/80 + I_"C" \
		=& (81 I_"C")/80 \
		=& #qty(101.25, "mA")
$ <f:eemitter>

Doing KCL on the emitter node gives us the current through $R_"EE"$ @f:ereei:

$
	I_"EE" = I_"E" - I_"DB" = #qty(21.25, "mA")
$ <f:ereei>

We know that the voltage on this node is @f:evoltage:

$
	V_"E" = V_"CC" - V_"CE" = #qty(5, "V")
$ <f:evoltage>

With this, we can solve for $R_"EE"$ and $R_"DB"$, as shown in @f:eree and @f:drdb.

$
	R_"EE" = V_"E"/I_"EE" = #qty(235.29, "O")
$ <f:eree>

$
	V_"CC" - V_"CE" - I_"DB" R_"DB" - V_"BE, sat" = 0 \
	R_"DB" = (V_"CC" - V_"CE" - V_"BE, sat")/I_"DB" = #qty(53.75, "O")
$ <f:drdb>

Finally, we can solve for the needed base resistor $R_"EB"$. This can be done
by doing KCL on the output node of the monostable multivibrator @f:ereb:

$
	I_"MC2" = I_"MB2" + I_"EB" = #qty(2.25, "mA") \
	V_"out, M" = V_"CC" - I_"MC2" R_"MC2" = #qty(4.69, "V") \
	R_"EB" = V_"out, M"/I_"EB" = #qty(3.75, "kO")
$ <f:ereb>

The last thing to do is to decide what flyback diode $D_"F"$ to use. We will
use the 1N4007, as it has a maximum surge current of #qty(30, "A") @1n4007,
which is much higher than the flyback current that it will experience with
regular use.

The full theoretical circuit is shown in @i:fulltheoretical.

#figure(
	image("assets/fulltheoretical.png"),
	caption: [Full diagram of the theoretical circuit.],
	placement: auto,
	scope: "parent"
) <i:fulltheoretical>

A table of the theoretical component values and models are shown in @t:astable,
@t:trigger, @t:monostable, @t:emitterfollower, and @t:chopper.

#figure(
	dtable(
		columns: 4,
		table.header[Component][Value/Model][Component][Value/Model],
		$Q_"A1"$ , [2N3904],
		$Q_"A2"$ , [2N3904],
		$R_"AC1"$, qty(580, "O"),
		$R_"AC2"$, qty(580, "O"),
		$R_"AB1"$, qty(5.25, "kO"),
		$R_"AB2"$, qty(5.25, "kO"),
		$C_"A1"$ , qty(24.98, "nF"),
		$C_"A2"$ , qty(24.98, "nF")
	),
	caption: [Component Values/Models for the Astable Multivbrator],
	placement: top
) <t:astable>

#figure(
	table(
		columns: 2,
		table.header[Component][Value/Model],
		$D_"T"$, [1N4148],
		$R_"T"$, qty(618.67, "O"),
		$C_"T"$, qty(14.69, "nF")
	),
	caption: [Component Values/Models for the Monostable Multivibrator\ Trigger],
	placement: top
) <t:trigger>

#figure(
	dtable(
		columns: 4,
		table.header[Component][Value/Model][Component][Value/Model],
		$Q_"M1"$       , [2N3904],
		$Q_"M2"$       , [2N3904],
		$R_"MC1"$      , qty(580, "O"),
		$R_"MC2"$      , qty(580, "O"),
		$R_"MB1, min"$ , qty(3.28, "kO"),
		$Delta R_"MB1"$, qty(1.97, "kO"),
		$R_"P"$        , qtyrange(0, 1, "MO"),
		$R_"MB2"$      , qty(4.67, "kO"),
		$C_"M"$       , qty(39.97, "nF")
	),
	caption: [Component Values/Models for the Monostable Multivbrator],
	placement: top
) <t:monostable>

#figure(
	table(
		columns: 2,
		table.header[Component][Value/Model],
		$Q_"E"$ , [2N4401],
		$R_"EB"$, qty(3.75, "kO"),
		$R_"EE"$, qty(235.29, "O")
	),
	caption: [Component Values/Models for the Emitter Follower],
	placement: top
) <t:emitterfollower>

#figure(
	dtable(
		columns: 4,
		table.header[Component][Value/Model][Component][Value/Model],
		$M$     , [#qty(6, "V") size 130 \ brushed DC motor],
		$Q_"D"$ , [TIP31C],
		$D_"F"$ , [1N4007],
		$R_"DB"$, qty(53.75, "O")
	),
	caption: [Component Values/Models for the DC Chopper]
)  <t:chopper>



= Simulation
== Original Values
In order to simulate the PWM motor controller system, we will use LTSpice.
First, we will be simulating the circuit using the original non-standard values
given in @t:astable, @t:trigger, @t:monostable, @t:emitterfollower, and
@t:chopper. For all simulations, we will step $R_"P"$ through its minimum and
maximum values: $R_"P, min" = #qty(0, "O")$ and $R_"P, max" = #qty(1, "MO")$. However,
LTSpice doesn't allow stepping with #qty(0, "O") resistors, so we'll instead
use a minimum of $R_"P, min" = #qty(1, "nO")$.

Also note, the motor was replaced by a #qty(7.19, "O") resistor. This was calculated
by doing a KVL through the motor and the TIP31C, and by taking into account the
stall current of the motor @f:motorresist:

$
	V_"CC" - I_"stall" R_"M" - V_"CE, sat" = 0 \
	R_"M" = (V_"CC" - V_"CE, sat")/I_"stall" = #qty(7.19, "O")
$ <f:motorresist>

With the original values, we get the following measurements, shown in
@t:original.

#figure(
	vstable(
		columns: 3,
		table.header[Measurement][$R_"P, min"$][$R_"P, max"$],
		[Frequency] , qty(6.17, "kHz"), qty(6.16, "kHz"),
		[Duty Cycle], qty(44.1, "%") , qty(69.59, "%")
	),
	caption: [Simulation Measurements of the Original Circuit]
) <t:original>

Unfortunately, all of our measured values are all out of spec, even considering
the tolerances. The divergence of values probably stem from the fact that the
$T = R C ln 2$ formula is not 100% accurate in practice; for example, the
capacitors don't discharge to #qty(0, "V"), they instead discharge to the CE
saturation voltage $V_"CE, sat" = #qty(0.2, "V")$. $V_"BE, sat"$ is also not
entirely accurate; the 2N3904 datasheet @2n3904 specifies a range and not a
constant value.

== Altered, Partially Standardized Components
In order to fix the discrepancies in the frequency and duty cycle of the system,
we will simply just try nearby standard values and find the values which
correspond to the least error in the measurements. As much as possible, we want
to avoid modifying the resistor values too much, as this may cause the
transistors to fall out of saturation. Instead, we'll vary the capacitors first,
and then vary the resistors.

The new values of various components are shown in @t:partialcomponents. Note that
these values may be combinations of two standard-valued components.

#figure(
	table(
		columns: 2,
		table.header[Component][New Value],
		$R_"AB1"$      , qty(5.4, "kO"),
		$R_"AB2"$      , qty(5.4, "kO"),
		$R_"MB1"$      , qty(4.1, "kO"),
		$Delta R_"MB1"$, qty(2.5, "kO"),
		$C_"A1"$       , qty(27, "nF"),
		$C_"A2"$       , qty(27, "nF"),
		$C_"M"$        , qty(39, "nF"),
	),
	caption: [New Component Values of the Partially Standardized Circuit]
) <t:partialcomponents>

With the new values, the new measurements are shown in @t:partial.

#figure(
	vstable(
		columns: 3,
		table.header[Measurement][$R_"P, min"$][$R_"P, max"$],
		[Frequency] , qty(5.50, "kHz"), qty(5.48, "kHz"),
		[Duty Cycle], qty(50.36, "%") , qty(79.91, "%")
	),
	caption: [Simulation Measurements of the Partially Standardized Circuit]
) <t:partial>

These values are now well within the specifications for frequency and duty cycle.

== Altered, Fully Standardized Components
The last step is to replace all other components with standard-valued near
equivalents. Standardizing all of the values reduced the frequency a bit, so
new values had to be picked for $R_"AB1"$ and $R_"AB2"$. The duty cycle
components were left unchanged. The new fully standardized values are shown
in @t:fullcomponents

#figure(
	dtable(
		columns: 4,
		table.header[Component][Value][Component][Value],
		$R_"AC1"$, qty(560, "O"),
		$R_"AC2"$, qty(560, "O"),
		$R_"AB1"$, qty(5.37, "kO"),
		$R_"AB2"$, qty(5.37, "kO"),
		$R_"T"$  , qty(620, "O"),
		$R_"MC1"$, qty(560, "O"),
		$R_"MC2"$, qty(560, "O"),
		$R_"MB2"$, qty(4.7, "kO"),
		$R_"EB"$ , qty(3.6, "kO"),
		$R_"EE"$ , qty(240, "O"),
		$R_"DB"$ , qty(51, "O"),
		$C_"T"$  , qty(15, "nF"),
	),
	caption: [New Component Values of the Fully Standardized Circuit],
	placement: top
) <t:fullcomponents>

With the fully standardized values, the new measurements are shown in @t:full.

#figure(
	vstable(
		columns: 3,
		table.header[Measurement][$R_"P, min"$][$R_"P, max"$],
		[Frequency] , qty(5.49, "kHz"), qty(5.48, "kHz"),
		[Duty Cycle], qty(50.26, "%") , qty(79.79, "%")
	),
	caption: [Simulation Measurements of the Fully Standardized Circuit]
) <t:full>

These values are still well within the specifications. Before we continue to
the physical implementation of the circuit, let's first check the wattages of
the relatively-high current resistors. In particular, we want to check $R_"DB"$
and $R_"EE"$. According to LTSpice, $I_"DB" approx #qty(45.9, "mA")$ and
$I_"EE" approx #qty(14.6, "mA")$. We can solve for the power dissipation of
the resistors as shown in @f:pdb and @f:pee.

$
	P_"DB" = I_"DB"^2 R_"DB" = #qty(107.45, "mW")
$ <f:pdb>

$
	P_"EE" = I_"EE"^2 R_"EE" = #qty(51.16, "mW")
$ <f:pee>

While both of these are well within the rating of a #qty(0.25, "W") resistor,
just to be safe, let's specify $R_"DB"$ to be a #qty(0.5, "W") resistor instead.



= Implementation
== Bill of Materials
At last, the bill of materials for the PWM motor controller system is shown in
@t:bill.

#figure(
	table(
		columns: 2,
		table.header[Component][Quantity],
		[TO-220 Heatsink]                       , num(1),
		[#qty(6, "V") size 130 brushed DC motor], num(1),
		[2N3904 NPN Transistor]                 , num(4),
		[2N4401 NPN Transistor]                 , num(1),
		[TIP31C NPN Transistor, TO-220]         , num(1),
		[1N4007 Rectifier Diode]                , num(1),
		[1N4148 Signal Diode]                   , num(1),
		[#qty(51, "O") Resistor, #qty(0.5, "W")], num(1),
		[#qty(100, "O") Resistor]               , num(1),
		[#qty(200, "O") Resistor]               , num(1),
		[#qty(240, "O") Resistor]               , num(1),
		[#qty(270, "O") Resistor]               , num(2),
		[#qty(560, "O") Resistor]               , num(4),
		[#qty(620, "O") Resistor]               , num(1),
		[#qty(2.4, "kO") Resistor]              , num(1),
		[#qty(3.6, "kO") Resistor]              , num(1),
		[#qty(3.9, "kO") Resistor]              , num(1),
		[#qty(4.7, "kO") Resistor]              , num(1),
		[#qty(5.1, "kO") Resistor]              , num(2),
		[#qty(15, "nF") Ceramic Capacitor]      , num(1),
		[#qty(27, "nF") Ceramic Capacitor]      , num(2),
		[#qty(39, "nF") Ceramic Capacitor]      , num(1)
	),
	caption: [Bill of Materials for the PWM Motor Controller System],
	placement: none
) <t:bill>
