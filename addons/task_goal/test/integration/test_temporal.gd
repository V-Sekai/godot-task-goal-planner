extends GutTest

func test_get_feasible_intervals_new_constraint() -> void:
	var resource: PlanResource = _create_resource_with_constraints()

	var start_time: int = 5
	var end_time: int = 35
	var duration: int = end_time - start_time
	var feasible_intervals: Array[TemporalConstraint] = resource.get_feasible_intervals(start_time, duration, 10)

	_validate_feasible_intervals(feasible_intervals)

func _create_resource_with_constraints() -> PlanResource:
	var simple_temporal_network = SimpleTemporalNetwork.new()
	var resource: PlanResource = PlanResource.new("Resource")
	resource.simple_temporal_network = simple_temporal_network

	var constraints = [
		TemporalConstraint.new(0, 10, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint"),
		TemporalConstraint.new(15, 15, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint"),
		TemporalConstraint.new(20, 5, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint")
	]

	for constraint in constraints:
		resource.simple_temporal_network.add_temporal_constraint(constraint)

	return resource

func _validate_feasible_intervals(feasible_intervals: Array) -> void:
	assert_eq(feasible_intervals.size(), 1, "Expected one feasible interval")

	var expected_interval = TemporalConstraint.new(15, 10, TemporalConstraint.TemporalQualifier.OVERALL, "feasible interval")
	if feasible_intervals.size():
		assert_eq(feasible_intervals[0], expected_interval, "Expected feasible interval not found")

func test_propagate_constraints() -> void:
	var mia = _create_resource_with_initial_constraint()

	var task_name = "Task 1"
	var start_time = 5
	var duration = 10
	var task_constraints = TemporalConstraint.new(start_time, duration, TemporalConstraint.TemporalQualifier.OVERALL, task_name)
	mia.simple_temporal_network.add_temporal_constraint(task_constraints)

	_validate_task_constraints(mia, task_name, start_time, duration)

func _create_resource_with_initial_constraint() -> PlanResource:
	var mia: PlanResource = PlanResource.new("Mia")
	var initial_constraint = TemporalConstraint.new(0, 25, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint")
	mia.simple_temporal_network.add_temporal_constraint(initial_constraint)
	return mia

func _validate_task_constraints(mia: PlanResource, task_name: String, start_time: int, duration: int) -> void:
	var task_constraints_added = false
	for constraint in mia.simple_temporal_network.constraints:
		if constraint.resource_name == task_name:
			task_constraints_added = true
			break

	assert_eq(task_constraints_added, true, "Expected task constraints to be added to STN")

	var constraint_task_name = mia.simple_temporal_network.get_temporal_constraint_by_name(mia, task_name)

	if constraint_task_name:
		var propagated_duration = constraint_task_name.duration
		assert_eq(propagated_duration, duration, "Expected duration to be propagated correctly")

		var temporal_constraint : TemporalConstraint = mia.simple_temporal_network.get_temporal_constraint_by_name(mia, task_name)
		var propagated_start_time = temporal_constraint.time_interval.x
		assert_eq(propagated_start_time, start_time, "Expected start time to be propagated correctly")

	assert_eq(mia.simple_temporal_network.is_consistent(), true, "Expected STN to be consistent after propagating constraints")

func test_task_duration_shorter_than_feasible_intervals() -> void:
	var mia: PlanResource = PlanResource.new("Mia")
	mia.simple_temporal_network.add_temporal_constraint(TemporalConstraint.new(10, 20, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint"))

	var start_time = 5
	var end_time = 15
	var duration = 5
	var task_constraints: Array[TemporalConstraint] = [
		TemporalConstraint.new(start_time, duration, TemporalConstraint.TemporalQualifier.OVERALL, "Feasible interval [10, 15]")
	]

	var feasible = mia.get_feasible_intervals(start_time, end_time, duration)
	assert_eq(feasible.size(), 0, "Expected no feasible intervals")
