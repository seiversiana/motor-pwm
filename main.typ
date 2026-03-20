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



= Source
The Git repository for this project is located at
https://github.com/seiversiana/motor-pwm. Included are the license, source code,
image files, and LTSpice files.



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
that is perfect for our purposes. From its datasheet @2n3904, we can
solve for its maximum frequency @f:2n3904freq:

$
	f_"max" = 1/(t_"d" + t_"r" + t_"s" + t_"f") = #qty(3.125, "MHz")
$ <f:2n3904freq>

Our needed frequency is safely within this limit. Now, since the astable
multivibrator cycles its transistors between cut-off and saturation, we need to
determine the currents and resistor values in order to let the transistors go
into saturation. From the datasheet @2n3904, we have $V_"CE, sat" = #qty(0.2, "V")$
and $V_"BE, sat" = #qtyrange(0.65, 0.85, "V")$ for current conditions
$I_"C" = #qty(10, "mA")$ and $I_"B" = #qty(1, "mA")$. Using this information, we
can solve for the needed resistor values. To simplify the calculations, let's
assume an average base saturation voltage $V_"BE, sat" = #qty(0.75, "V")$
instead.

In order to further simplify calculations and reduce the number of unique
components, we can recognize that the duty cycle of this stage does not matter,
since only the rising edge of the output will be used to trigger the monostable
multivibrator. This is independent of duty cycle, and only requires that the
frequency be constant. Therefore, we assume a duty cycle of #qty(50, "%")
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
since the currents needed to saturate the transistors stay the same. For this
stage, we want the duty cycle to vary throughout the range of $D_"S"$, which is
done by varying $R_"MB1"$. Note that $R_"MB1" = R_"AB"$ is the maximum value of
the resistor; going above this will not supply the base of $Q_"M2"$ with enough
current to sustain saturation with $I_"C" = #qty(10, "mA")$. Now, since the duty
cycle of this stage $D_"M"$ is directly proportional to $R_"MB1"$, we want
$R_"MB1, max" = R_"AB"$ to give us the maximum duty cycle $D_"S, max" = #qty(80, "%")$.

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

From this, we have a resistance difference of $Delta R_"MB1" = #qty(1.97, "kO")$. In
order to vary $R_"MB1"$ throughout its minimum and maximum values, we can have
a resistor network as shown in @i:rmb1.

#figure(
	image("assets/rmb1.png"),
	caption: [Resistor network equivalent of $R_"MB1"$.]
) <i:rmb1>

Here, $R_"P"$ is the potentiometer resistance, where $R_"P, max" >> Delta R_"MB1"$,
and $R_"P, min" = #qty(0, "O")$. This makes it so that when $R_"P" = R_"P, min"$, then
$R_"MB1" = R_"MB1, min"$, and when $R_"P" = R_"P, max"$, then
$R_"MB1" approx R_"MB1, max"$. Let's use a potentiometer resistance $R_"P" = #qtyrange(0, 100, "kO")$, so
that there is minimal deviation between the original and maximum varied
$R_"MB1, max"$.

Next, we can solve for $R_"MB2"$. Recall that the base current $I_"B"$ should be
#qty(1, "mA") for saturation with $I_"C" = #qty(10, "mA")$ @2n3904, which means that the equivalent resistance must
allow for this. Fortunately, we have already calculated this value before in @f:abase.
Setting $R_"MC2" = R_"MC1"$ and solving for $R_"MB2"$ @f:rmb2:

$
	R_"MB2" = R_"AB" - R_"MC2" = #qty(4.67, "kO")
$ <f:rmb2>

Finally, we need to solve for the values for the coupling. First, we need to
select the diode for $D_"T"$. The 1N4148 is a high-speed switching diode which
is perfect for this purpose. From its datasheet @1n4148, we can calculate
its maximum frequency  @f:1n4148freq:

$
	f_"max" = 1/t_"rr" = #qty(250, "MHz")
$ <f:1n4148freq>

Our specified frequency is safely within this limit. Next, we want to solve for
$C_"T"$ and $R_"T"$. Note that we are triggering the monostable multivibrator
using the falling edge of the astable multivibrator. This gives a negative
voltage at the base of $Q_"M2"$ causing it to turn off and $Q_"M1"$ to turn on.
$Q_"A2"$ will also turn on during this time, which means that we have an RC
circuit with $R_"T"$, $R_"MB1"$, and $C_"T"$ that discharges through $Q_"A2"$.

We want the negative pulse to last long enough to trigger the cross-coupling of the
monostable multivibrator, but also short enough that it doesn't retrigger it. A
good baseline value for this would be #qty(10, "%") of $T_"off"$. Let's use the
formula @f:2rc:

$
	T = 2 R C
$ <f:2rc>

This gets us #qty(86.5, "%") the way to completely discharging the capacitor,
which is probably good enough for this calculation. Note that $R$ here would be the parallel
resistors $R_"T"$ and $R_"MB2"$, and we will be using $R_"MB2" = R_"MB2, max"$
so that we'll be solving for the maximum negative pulse time. Setting up
the equation for $R_"T"$ and $C_"T"$ @f:ctrtd:

$
	#qty(5, "%")/f_"S" =& 2 C_"T" dot (R_"T" R_"MB2, max")/(R_"T" + R_"MB2, max")
$ <f:ctrtd>

Now, there isn't really a single value for $C_"T"$ and $R_"T"$ since we only have
one equation. So let's set $C_"T" = #qty(15, "nF")$ since this is what I have on
hand, and solve for $R_"T"$. We finally get @f:rt:

$
	R_"T" = #qty(321.59, "O")
$ <f:rt>

== Emitter Follower and DC Chopper
The circuit diagram of the DC chopper coupled to the emitter follower and
the monostable multivibrator is shown in @i:chopper.

#figure(
	image("assets/chopper.png"),
	caption: [
		Circuit diagram of the DC chopper coupled to the emitter follower and
		the monostable multivibrator.
	]
) <i:chopper>

In order to analyze this final section, we first need to know the collector current of
$Q_"D"$. A common stall current for a #qty(6, "V")
size 130 brushed motor is around #qty(800, "mA"), which will be the maximum
$I_"C"$ of $Q_"D"$. For this, we will need to use a power transistor. One such
transistor is the TIP31C, which can handle up to #qty(3, "A") of collector
current @tip31c, which is more than enough for our needs. In order to get our
collector current, we need to saturate the transistor by forcing $beta = 10$ or
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
an emitter follower does not go into saturation; it sits inside forward-active instead.
From the datasheet @2n4401, the closest $beta$ for our $I_C$ is
$beta = 80$, with $V_"CE" = #qty(1, "V")$. Therefore, we will need a base
current $I_"B" = #qty(1.25, "mA")$ for the emitter follower.

Now, we solve for $I_"E"$, $R_"EE"$, and $R_"DB"$. Solving for $I_"E"$ @f:eemitter:

$
	I_"E" =& I_"B" + I_"C" = (81 I_"C")/80 = #qty(101.25, "mA")
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

The full theoretical circuit is shown in @i:fulltheoretical. A table of the
theoretical component values and models are shown in @t:astable,
@t:trigger, @t:monostable, @t:emitterfollower, and @t:chopper.

#figure(
	image("assets/fulltheoretical.png"),
	caption: [Full diagram of the theoretical circuit.],
	placement: auto,
	scope: "parent"
) <i:fulltheoretical>

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
	caption: [Component Values/Models for the Astable Multivibrator],
	placement: top
) <t:astable>

#figure(
	table(
		columns: 2,
		table.header[Component][Value/Model],
		$D_"T"$, [1N4148],
		$R_"T"$, qty(321.59, "O"),
		$C_"T"$, qty(15, "nF")
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
		$R_"P"$        , qtyrange(0, 100, "kO"),
		$R_"MB2"$      , qty(4.67, "kO"),
		$C_"M"$       , qty(39.97, "nF")
	),
	caption: [Component Values/Models for the Monostable Multivibrator],
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
== Theoretical Values
In order to simulate the PWM motor controller system, we will use LTSpice.
First, we will be simulating the circuit using the original non-standard values
given in @t:astable, @t:trigger, @t:monostable, @t:emitterfollower, and
@t:chopper. For all simulations, we will step $R_"P"$ through its minimum and
maximum values: $R_"P, min" = #qty(0, "O")$ and $R_"P, max" = #qty(100, "kO")$. However,
LTSpice doesn't allow stepping with #qty(0, "O") resistors, so we'll instead
use a minimum potentiometer resistance $R_"P, min" = #qty(1, "nO")$.

Also note, the motor was replaced by a #qty(7.19, "O") resistor. This was calculated
by doing a KVL through the motor and the TIP31C, and by taking into account the
stall current of the motor @f:motorresist:

$
	V_"CC" - I_"stall" R_"M" - V_"CE, sat" = 0 \
	R_"M" = (V_"CC" - V_"CE, sat")/I_"stall" = #qty(7.19, "O")
$ <f:motorresist>

With the theoretical values, we get the following measurements, shown in
@t:theoretical.

#figure(
	vstable(
		columns: 3,
		table.header[Measurement][$R_"P, min"$][$R_"P, max"$],
		[Frequency] , qty(5.21, "kHz"), qty(5.21, "kHz"),
		[Duty Cycle], qty(52.33, "%") , qty(75.5, "%")
	),
	caption: [Simulation Measurements of the Theoretical Circuit]
) <t:theoretical>

Sadly, our frequencies here are out of spec by about #qty(300, "Hz"). Our duty
cycles are okay, but as much as possible we want them to be as close as possible
to the specifications, so that real life tolerances won't nudge it out of the specified ranges.

One problem is that the equation for the frequency of an astable multivibrator
is just an ideal model, which assumes that the transistors instantly switch from
cut-off to saturation, and that $V_"BE"$ and $V_"CE"$ are constant. It also doesn't
take into account the fact that the astable multivibrator might be loaded; in our case,
it is loaded by the monostable multivibrator trigger circuit, which may have caused
the frequencies to drift.

Our duty cycles are a lot closer, but they can be better. A probable cause for
this is the fact that setting $R_"P, max" = #qty(100, "kO")$ is not enough to eliminate
itself from the total value of $R_"MB1"$. Recall that as $R_"P, max" -> +oo$,
$R_"MB1" -> R_"MB1, max"$ because $Delta R_"MB1"$ and $R_"P"$ are in parallel.
The monostable multivibrator is also loaded in our case by the emitter follower
circuit, however not by much.

Here, LTSpice is more accurate since it models a lot more variables than just
the RC time constant.

== Partly Standardized Values
In order to fix the discrepancies in frequency and duty cycle, all we can really do
is vary the timing components until the frequency and duty cycle are within the
specifications. We can also now pick standard values for the components here.

For both multivibrators, we will pick a standard value for the timing capacitors
first, then vary the timing resistors until the frequency and duty cycle are within
the specifications. The new values are shown in @t:partlycomponents, and the measurements
of the circuit are shown in @t:partlymeasurements.

#figure(
	dtable(
		columns: 4,
		table.header[Component][Value][Component][Value],
		$R_"AB1"$      , qty(4.62, "kO"),
		$R_"AB2"$      , qty(4.62, "kO"),
		$R_"MB1, min"$ , qty(3, "kO"),
		$Delta R_"MB1"$, qty(2.5, "kO"),
		$C_"A1"$       , qty(27, "nF"),
		$C_"A2"$       , qty(27, "nF"),
		$C_"M"$        , qty(39, "nF"),
	),
	caption: [Partly Standardized Component Values],
	placement: top
) <t:partlycomponents>

#figure(
	vstable(
		columns: 3,
		table.header[Measurement][$R_"P, min"$][$R_"P, max"$],
		[Frequency] , qty(5.49, "kHz"), qty(5.49, "kHz"),
		[Duty Cycle], qty(50.05, "%") , qty(79.97, "%")
	),
	caption: [Simulation Measurements of the Partly Standardized Circuit],
	placement: top
) <t:partlymeasurements>

The frequency and duty cycle is now within specifications. Note that the
#qty(4.62, "kO") resistors are actually two #qty(2.2, "kO") resistors and a
#qty(220, "O") resistor in series, and the #qty(2.5, "kO") resistor is actually
two #qty(150, "O") resistors and a #qty(2.2, "kO") resistor in series.

== Completely Standardized Values
Lastly, we will need to pick standard values for all of the components. The measurements
will change here, so we'll also pick new values for them if ever they change
too much. The new values are shown in @t:completelycomponents, and the measurements
of the circuit are shown in @t:completelymeasurements.

#figure(
	dtable(
		columns: 4,
		table.header[Component][Value][Component][Value],
		$R_"AC1"$      , qty(560, "O"),
		$R_"AC2"$      , qty(560, "O"),
		$R_"T"$        , qty(330, "kO"),
		$R_"MC1"$      , qty(560, "O"),
		$R_"MC2"$      , qty(560, "O"),
		$R_"MB2"$      , qty(4.7, "kO"),
		$R_"EB"$       , qty(3.6, "kO"),
		$R_"EE"$       , qty(240, "O"),
		$R_"DB"$       , qty(51, "O"),
	),
	caption: [Completely Standardized Component Values],
	placement: top
) <t:completelycomponents>

#figure(
	vstable(
		columns: 3,
		table.header[Measurement][$R_"P, min"$][$R_"P, max"$],
		[Frequency] , qty(5.49, "kHz"), qty(5.49, "kHz"),
		[Duty Cycle], qty(50.11, "%") , qty(80.2, "%")
	),
	caption: [Simulation Measurements of the Completely Standardized Circuit],
	placement: top
) <t:completelymeasurements>

Fortunately, the measurements didn't change too much, and they are still well within
the specifications. Before we move on, let's check the power dissipation of the
resistors. The resistor with the highest power dissipation is $R_"DB"$ at around
#qty(106.54, "mW"). Let's specify $R_"DB"$ to be a #qty(0.5, "W") resistor instead,
just to be safe.



= Actual Construction
== Bill of Materials and Changed Components
At last, shown in @t:bill is the bill of materials for the PWM motor controller.

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
		[#qty(100, "kO") Potentiometer]         , num(1),
		[#qty(51, "O") Resistor, #qty(0.5, "W")], num(1),
		[#qty(150, "O") Resistor]               , num(2),
		[#qty(220, "O") Resistor]               , num(2),
		[#qty(240, "O") Resistor]               , num(1),
		[#qty(330, "O") Resistor]               , num(1),
		[#qty(560, "O") Resistor]               , num(4),
		[#qty(2.2, "kO") Resistor]              , num(5),
		[#qty(3, "kO") Resistor]                , num(1),
		[#qty(3.6, "kO") Resistor]              , num(1),
		[#qty(4.7, "kO") Resistor]              , num(1),
		[#qty(15, "nF") Ceramic Capacitor]      , num(1),
		[#qty(27, "nF") Ceramic Capacitor]      , num(2),
		[#qty(39, "nF") Ceramic Capacitor]      , num(1)
	),
	caption: [Bill of Materials for the PWM Motor Controller System],
	placement: top
) <t:bill>

Unfortunately, I wasn't able to procure all of these components exactly; some
resistors in particular are not the right values. However, none of them
were the important timing resistors, so close, but not quite right values for them are fine.
The list of changed components is found in @t:changed.

#figure(
	table(
		columns: 2,
		table.header[Component][New Value/Model],
		$R_"EB"$, [#qty(3.3, "kO") Resistor],
		$R_"DB"$, [#qty(50, "O") Resistor, #qty(0.5, "W")],
		$C_"A1"$, [#qty(27, "nF") Mylar Capacitor],
		$C_"A2"$, [#qty(27, "nF") Mylar Capacitor],
		$C_"M"$ , [#qty(39, "nF") Mylar Capacitor],
	),
	caption: [List of Changed Components],
	placement: top
) <t:changed>

The mylar capacitors are fine in our case since our frequency specifications are
relatively low. The lower values for $R_"EB"$ and $R_"DB"$ doesn't really matter
since the collector currents are already limited for their respective transistors.
There will be a higher emitter current for those transistors, but that isn't
a problem.

== Breadboard Construction
The breadboard construction of the circuit is shown in @i:breadboard.

#figure(
	rotate(-90deg, image("assets/breadboard.jpg"), reflow: true),
	caption: [Breadboard construction of the PWM motor controller.],
	placement: top
) <i:breadboard>

The voltage source here is a pack of four #qty(1.5, "V") AA batteries in series. From the
last simulation, the current through the voltage source was around #qty(800, "mA").
The carbon-zinc batteries that I am using are not at all suitable for this use-case,
as they have high internal resistances especially when used under this amount of current.
This is shown by the fact that the breadboard circuit does not generate the
expected #qty(5.5, "kHz") square wave; the frequency is around #qty(5.3, "kHz") instead.
From LTSpice, this is consistent with a voltage source of #qty(4, "V"), which confirms
that each of the batteries have dropped to around #qty(1, "V") trying to sustain
the high current. For this, alkaline batteries should be used instead.

In order to test the frequency of the circuit at home without an oscilloscope, I simply
connected the output which was normally connected to the motor to a pair of unused
headphones. I compared the sound from the headphones to an online square wave generator,
and varied the frequency on the website until both of the sounds matched. Doing this
also confirmed that the multivibrators were working, since there wouldn't be any sound
coming from the headphones if there wasn't some output wave from the circuit.
