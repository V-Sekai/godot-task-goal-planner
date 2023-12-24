# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_performance.gd
# SPDX-License-Identifier: MIT

extends "res://addons/gut/test.gd"

var stn: SimpleTemporalNetwork = null


func before_each():
	stn = SimpleTemporalNetwork.new()


func calculate_time_interval(i, temporal_qualifier):
	if temporal_qualifier == 1:
		return [i * 10, i * 10 + 5]
	else:
		return [(i * 10) + 5, (i + 1) * 10]


func test_performance_with_large_number_of_constraints():
	var start_time = Time.get_ticks_msec()

	for i in range(1300):
		var qualifier_1 = TemporalConstraint.TemporalQualifier.AT_START
		var interval_1 = calculate_time_interval(i, qualifier_1)
		var from_constraint = TemporalConstraint.new(interval_1[0], interval_1[1], 5, qualifier_1, "from" + str(i))
		var qualifier_2 = TemporalConstraint.TemporalQualifier.AT_END
		var interval_2 = calculate_time_interval(i + 1, qualifier_2)
		var to_constraint = TemporalConstraint.new(interval_2[0], interval_2[1], 5, qualifier_2, "to" + str(i))

		# Add constraints and propagate them.
		stn.add_temporal_constraint(from_constraint, to_constraint, 0, 10)

	assert_true(stn.is_consistent(), "Consistency test failed: STN should be consistent")
	var end_time = Time.get_ticks_msec()
	var time_taken = end_time - start_time
	gut.p("Time taken for constraints: " + str(time_taken) + " ms")
	assert_true(time_taken < 1000, "Performance test failed: Time taken should be faster than 1 second")
