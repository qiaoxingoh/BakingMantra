# candy_icicle.gd
extends Area2D

@export var freeze_duration: float = 2.0
@export var damage: int = 1
@export var fall_gravity: float = 200.0  # Higher value for Area2D
@export var fall_speed: float = 50.0

var is_falling: bool = false
var original_position: Vector2
var velocity: Vector2 = Vector2.ZERO

@onready var sprite = $AnimatedSprite2D

func _ready():
	# Save original position
	original_position = global_position
	
	# MOVE DetectionZone - adjust as needed
	$DetectionZone.position = Vector2(0, 3)
	
	# Play hanging animation
	sprite.play("hang")

func _on_detection_zone_body_entered(body):
	if body.is_in_group("player") and not is_falling:
		start_falling()

func start_falling():
	is_falling = true
	
	# Set initial velocity for falling
	velocity = Vector2(0, fall_speed)
	
	# Play falling animation
	sprite.play("fall")

func _physics_process(delta):
	if is_falling:
		# Apply gravity and move manually
		velocity.y += fall_gravity * delta
		position.y += velocity.y * delta
		
		# Check if hit ground or went off-screen
		if position.y > 1000:  # Adjust based on your screen size
			shatter()

func _on_damage_area_body_entered(body):
	if body.is_in_group("player") and is_falling:
		
		# Damage player
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		# Freeze player
		if body.has_method("freeze"):
			body.freeze(freeze_duration)
		
		# Icicle shatters
		shatter()

func shatter():
	# Play break animation
	sprite.play("break")
	
	# Stop falling
	is_falling = false
	velocity = Vector2.ZERO
	
func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "break":
		queue_free()

# Optional: Respawn functionality
func respawn():
	global_position = original_position
	is_falling = false
	velocity = Vector2.ZERO
	sprite.play("hang")
	
	# Re-enable collisions
	$CollisionShape2D.disabled = false
	$DamageArea/CollisionShape2D.disabled = false
	$DetectionZone/CollisionShape2D.disabled = false
