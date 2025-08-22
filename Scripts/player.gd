extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

@export var walk_speed = 150.0
@export var run_speed = 250.0
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1

@export var jump_force = -600.0
@export_range(0, 1) var decelerate_on_jump_release = 0.3

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var inventory = {}

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or is_on_wall()):
		velocity.y = jump_force
		animated_sprite.play("Jump")
	
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release
		
	var speed
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walk_speed;
		
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Handle movement
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)
	
	#Handle animations
	if not is_on_floor() and velocity.y < 0 and Input.is_action_pressed("ui_accept"):
		animated_sprite.play("Jump")
	elif not is_on_floor() and velocity.y > 0:
		animated_sprite.play("Fall") 
	elif abs(velocity.x) > 0.1:
		animated_sprite.play("Walk")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.play("Idle")

	# Move the character
	move_and_slide()
	
func collect_item(item_name):
	# Add item to inventory or increase count
	if inventory.has(item_name):
		inventory[item_name] += 1
	else:
		inventory[item_name] = 1
	
	print("Collected: ", item_name, " - Total: ", inventory[item_name])
