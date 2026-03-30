extends RigidBody3D

var throw_force: float = 10.0

func throw(direction: Vector3):
	linear_velocity = direction * throw_force
