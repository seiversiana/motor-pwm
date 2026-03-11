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



= Theoretics
== Specifications
We are tasked to create a PWM motor controller by cascading an astable
multivibrator, a monostable multivibrator, an emitter follower, and finally a
DC chopper circuit. Only BJTs may be used. @f:spec shows the input and output
specifications of the system.

$
	V_"CC" = #qty(6, "V") \
	f_S = #qty("5.5+-0.1", "kHz") \
	D_(S, "max") = #qty("80+-5", "%") \
	D_(S, "min") = #qty("50+-5", "%")
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

== Astable Multivibrator
The circuit diagram of the astable multivibrator is shown in @i:astable.

#figure(
	image("assets/astable.svg"),
	caption: [Circuit diagram of the astable multivibrator.]
) <i:astable>
