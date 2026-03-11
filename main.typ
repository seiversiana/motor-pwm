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
