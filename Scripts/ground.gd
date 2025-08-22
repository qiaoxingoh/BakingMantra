# ground.gd
extends StaticBody2D

func _ready() -> void:
	pass # Signals are already connected in the editor

func _on_ground_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player is sliding on ice!")
		var ice_physics = PhysicsMaterial.new()
		ice_physics.friction = 0.1
		body.physics_material_override = ice_physics

func _on_ground_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player left the ice area")
		body.physics_material_override = null
