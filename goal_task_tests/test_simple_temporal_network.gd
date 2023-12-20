# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_simple_temporal_network.gd
# SPDX-License-Identifier: MIT

extends "res://addons/gut/test.gd"

var stn: SimpleTemporalNetwork = null


func before_each():
	stn = SimpleTemporalNetwork.new()


func test_to_dictionary():
	var result = stn.to_dictionary()
	assert_eq(typeof(result), TYPE_DICTIONARY, "to_dictionary should return a Dictionary")


func test_get_node_index():
	var node_interval = Vector2i(1, 2)
	var index = stn.get_node_index(node_interval)
	assert_eq(index, -1, "get_node_index should return -1 for non-existing node")


func test_init_matrix():
	var num_nodes = 3
	stn._init_matrix(num_nodes)
	assert_eq(stn.row_indices.size(), num_nodes)
	assert_eq(stn.col_indices.size(), num_nodes)
	assert_eq(stn.values.size(), num_nodes)


func test_add_temporal_constraint():
	var from_constraint = TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")
	var result = stn.add_temporal_constraint(from_constraint)
	assert_true(result, "add_temporal_constraint should return true when adding valid constraint")


func test_get_temporal_constraint_by_name():
	var constraint = TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")
	stn.constraints.append(constraint)
	var result = stn.get_temporal_constraint_by_name("resource")
	assert_eq(result, constraint, "get_temporal_constraint_by_name should return the correct constraint")


func test_propagate_constraints():
	var num_nodes = 3
	stn._init_matrix(num_nodes)
	var result = stn.propagate_constraints()
	assert_true(result, "propagate_constraints should return true when there are no negative diagonal values")


func test_is_consistent():
	var result = stn.is_consistent()
	assert_true(result, "is_consistent should return true when constraints are consistent")


func test_update_state():
	var state = {"constraint": TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")}
	stn.update_state(state)
	assert_eq(stn.constraints.size(), 1, "update_state should add the constraint to the constraints array")


func test_is_consistent_with():
	var constraint = TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")
	stn.add_temporal_constraint(constraint)
	var result = stn.is_consistent_with(constraint)
	assert_true(result, "is_consistent_with should return true when the network is consistent with the given constraint")


func test_print_constraints_and_check_consistency():
	var constraint = TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")
	stn.add_temporal_constraint(constraint)
	for i in range(stn.constraints.size()):
		gut.p("Constraint " + str(i) + ": " + str(stn.constraints[i].to_dictionary()), gut.LOG_LEVEL_ALL_ASSERTS)
	var result = stn.is_consistent()
	assert_true(result, "is_consistent should return true when the network is consistent")


func test_validate_constraints():
	var from_constraint = TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")
	var to_constraint = TemporalConstraint.new(4, 5, 6, TemporalConstraint.TemporalQualifier.AT_END, "resource")
	assert_true(stn.validate_constraints(from_constraint, to_constraint, 0, 0), "validate_constraints should return true when constraints are valid")


func test_add_constraints_to_list():
	var from_constraint = TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")
	stn.add_constraints_to_list(from_constraint, null)
	assert_eq(stn.constraints.size(), 1, "add_constraints_to_list should add one constraint to the list")


func test_process_constraint():
	var from_constraint = TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")
	var node_index = stn.process_constraint(from_constraint)
	assert_true(node_index != -1, "process_constraint should return a valid node index")


func test_reset_matrix():
	var from_node = 0
	var to_node = 1
	stn.reset_matrix(from_node, to_node)
	assert_true(stn.is_consistent(), "reset_matrix shoudl return true when the matrix is reset")


func test_update_matrix_single():
	var from_node = 0
	assert_true(stn.update_matrix_single(from_node), "update_matrix_single should return true when matrix is updated successfully")


func test_init_and_reset_matrix():
	var from_node = 0
	var to_node = 1
	stn._init_matrix(2)
	stn.reset_matrix(from_node, to_node)
	assert_true(stn.is_consistent(), "reset_matrix should return true when the matrix is reset")


func test_init_and_update_matrix_single():
	var from_node = 0
	stn._init_matrix(1)
	assert_true(stn.update_matrix_single(from_node), "update_matrix_single should return true when matrix is updated successfully")
