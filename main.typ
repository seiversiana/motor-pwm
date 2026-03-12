// SPDX-FileCopyrightText: Copyright (C) Nile Jocson <seiversiana@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#import "@preview/charged-ieee:0.1.4": ieee

#import "@preview/fletcher:0.5.8": diagram, node, edge
#import "@preview/unify:0.7.1": qty, qtyrange

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
	caption: [Block diagram of the PWM motor controller system.]
) <d:block>

== Astable Multivibrator <s:astable>
The circuit diagram of the astable multivibrator is shown in @i:astable.

#figure(
	image("assets/astable.png"),
	caption: [Circuit diagram of the astable multivibrator.]
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
the resistor; going above this will not supply the base of $U_"M2"$ with enough
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
$R_"MB1" = R_"MB1, min"$, and when $R_"P" = R_"P, max"$, $R_"MB1" approx R_"MB1, max"$.

Finally, we need to solve for the values for the coupling. First, we need to
select the diode for $D_"T"$. The 1N4148 is a high-speed switching diode which
is perfect for this purpose. From its datasheet @1n4148, we can calculate
its maximum frequency  @f:1n4148freq:

$
	f_"max" = 1/t_"rr" = #qty(250, "MHz")
$ <f:1n4148freq>

Our needed frequency is way within this limit. Now, we want a sufficient current
at the base of $U_"M1"$ so that the transistor will reliably discharge $C_"M"$ and
allow the cross-coupling to take over. Let's assume $I_"C" = #qty(50, "mA")$ and
$I_"B" = #qty(5, "mA")$. This gives us a $V_"BE, sat" = #qty(0.95, "V")$
@2n3904. Note that the forward voltage of the 1N4148 at this current is
$V_"F" = #qty(0.65, "V")$ @1n4148. With this information, we can solve for
$I_"out, A"$ by doing KVL through $R_"AC2"$ and the base of $U_"M1"$ @f:aouti:

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
