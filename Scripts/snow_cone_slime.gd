# snow_cone_slime.gd
extends CharacterBody2D

@export var speed: int = 75
@export var damage: int = 1
@export var ice_shard_damage: int = 1
@export var attack_cooldown: float = 3.0

var direction: int = -1
var can_attack: bool = true
var player_in_range: bool = false
var is_squished: bool = false
var is_attacking: bool = false
var gravity: int = 980

@onready var sprite = $AnimatedSprite2D

func _ready():
	$RayCast2D.target_position = Vector2(30 * direction, 30)
	$RayCast2D.enabled = true
	
	$AttackTimer.wait_time = attack_cooldown
	$AttackTimer.start()
	sprite.play("walk")

func _physics_process(delta):
	if is_squished or is_attacking:
		return
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Reset when on floor
	
	# Only move horizontally if on floor
	if is_on_floor():
		velocity.x = speed * direction
	else:
		velocity.x = 0  # Stop horizontal movement in air
	
	move_and_slide()
	
	# Only check for turning when on floor
	if is_on_floor():
		if is_on_wall() or !$RayCast2D.is_colliding():
			turn_around()
	
	# Handle animations based on state
	handle_animations()

func handle_animations():
	if is_squished:
		return
	elif is_attacking:
		sprite.play("attack")
	elif not is_on_floor():
		sprite.play("walk")  # Or create a "fall" animation later
	elif abs(velocity.x) > 0:
		sprite.play("walk")
	else:
		sprite.play("walk")

func turn_around():
	direction *= -1
	sprite.scale.x *= -1
	$RayCast2D.target_position.x *= -1

func throw_snowball():
	if not can_attack or is_squished:
		return
	
	can_attack = false
	is_attacking = true
	velocity.x = 0
	sprite.play("attack")
	
	print("Snow Cone Slime attacks!")
	
	await get_tree().create_timer(0.8).timeout
	is_attacking = false
	$AttackTimer.start()

func take_damage(amount: int = 1):
	if is_squished or is_attacking:
		return
	
	print("Slime took ", amount, " damage!")
	sprite.play("get_hit")
	velocity.x = 0
	
	velocity.y = -100
	
	await get_tree().create_timer(0.2).timeout
	sprite.play("walk")

func squish():
	if is_squished:
		return
	
	is_squished = true
	velocity.x = 0
	sprite.play("death")
	
	$CollisionShape2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	
	await get_tree().create_timer(0.8).timeout
	queue_free()

func _on_attack_timer_timeout():
	if player_in_range and can_attack and not is_squished:
		throw_snowball()
	else:
		can_attack = true

func _on_detection_zone_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_detection_zone_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and not is_squished and not is_attacking:
		if body.has_method("take_damage"):
			body.take_damage(damage)

func _on_stomp_detector_body_entered(body):
	if body.is_in_group("player") and body.velocity.y > 0 and not is_squished:
		squish()
		body.velocity.y = -300
