# candy_icicle.gd
extends RigidBody2D

@export var fall_gravity: float = 3.0
var has_fallen: bool = false

func _ready():
	# Start with no gravity
	gravity_scale = 0.0
	# Make sure it doesn't rotate randomly
	freeze = true

func _on_detection_zone_body_entered(body):
	if body.is_in_group("player") and !has_fallen:
		start_falling()

func start_falling():
	has_fallen = true
	gravity_scale = fall_gravity
	freeze = false  # Let physics take over
	# Play cracking sound effect if you have one
	print("Icicle falling!")
	
	# Optional: Add a slight delay before enabling damage
	await get_tree().create_timer(0.2).timeout
	$DamageArea.monitoring = true

func _on_damage_area_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(1)  # Hurt player
		# Icicle breaks after hitting player
		shatter()

func shatter():
	# Play break animation/sound
	print("Icicle shattered!")
	# Disable collisions
	$CollisionShape2D.disabled = true
	$Sprite2D.hide()
	# Remove after a delay
	await get_tree().create_timer(0.3).timeout
	queue_free()
