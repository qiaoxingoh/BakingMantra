# snow_cone_slime.gd
extends CharacterBody2D

@export var speed: int = 75
@export var damage: int = 1
@export var ice_shard_damage: int = 1
@export var attack_cooldown: float = 3.0
@export var snow_trail_interval: float = 0.5

var direction: int = -1
var can_attack: bool = true
var player_in_range: bool = false
var is_squished: bool = false
var is_attacking: bool = false
var snow_trail_timer: float = 0.0

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

func _ready():
	$RayCast2D.target_position = Vector2(50 * direction, 0)
	$AttackTimer.wait_time = attack_cooldown
	$AttackTimer.start()
	play_animation("idle")

func _physics_process(delta):
	if is_squished or is_attacking:
		return
	
	# Movement
	velocity.x = speed * direction
	move_and_slide()
	
	# Create snow trail
	snow_trail_timer += delta
	if snow_trail_timer >= snow_trail_interval and is_on_floor():
		create_snow_trail()
		snow_trail_timer = 0.0
	
	# Turn around at walls/edges
	if is_on_wall() or !$RayCast2D.is_colliding():
		turn_around()
	
	# Play walk animation when moving
	if abs(velocity.x) > 0:
		play_animation("walk")
	else:
		play_animation("idle")
	
	# Attack if player is in range
	if player_in_range and can_attack:
		throw_snowball()

func turn_around():
	direction *= -1
	sprite.scale.x *= -1
	$RayCast2D.target_position.x *= -1

func throw_snowball():
	if not can_attack:
		return
	
	can_attack = false
	is_attacking = true
	play_animation("attack")
	
	# Wait for attack animation to reach throwing frame
	await get_tree().create_timer(0.3).timeout
	
	# Create snowball projectile
	var snowball = preload("res://Projectiles/snow_ball.tscn").instantiate()
	get_parent().add_child(snowball)
	snowball.global_position = global_position + Vector2(20 * direction, -10)
	snowball.direction = direction
	snowball.damage = ice_shard_damage
	
	# Wait for animation to finish
	await get_tree().create_timer(0.5).timeout
	is_attacking = false
	$AttackTimer.start()

func create_snow_trail():
	var snow_trail = Sprite2D.new()
	snow_trail.texture = preload("res://assets/level3/enemy/snow.png")
	snow_trail.global_position = global_position + Vector2(0, 15)
	snow_trail.z_index = -1  # Behind the slime
	get_parent().add_child(snow_trail)
	
	# Remove snow trail after some time
	await get_tree().create_timer(5.0).timeout
	if is_instance_valid(snow_trail):
		snow_trail.queue_free()

func play_animation(anim_name):
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

func take_damage(amount):
	if is_squished:
		return
	
	play_animation("get_hit")
	# Add knockback or other effects
	await get_tree().create_timer(0.2).timeout

func squish():
	if is_squished:
		return
	
	is_squished = true
	play_animation("death")
	
	# Disable collisions
	$CollisionShape2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	
	# Wait for death animation
	await get_tree().create_timer(0.8).timeout
	queue_free()

func _on_attack_timer_timeout():
	can_attack = true

func _on_detection_zone_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_detection_zone_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and not is_squished:
		if body.has_method("take_damage"):
			body.take_damage(damage)

func _on_stomp_detector_body_entered(body):
	if body.is_in_group("player") and body.velocity.y > 0 and not is_squished:
		squish()
		if body.has_method("bounce"):
			body.bounce()
