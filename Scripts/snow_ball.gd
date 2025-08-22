# snow_ball.gd
extends Area2D

@export var speed: int = 250
@export var damage: int = 1
var direction: int = 1

@onready var sprite = $Sprite2D

func _ready():
	# Auto-remove after 3 seconds
	$LifetimeTimer.wait_time = 3.0
	$LifetimeTimer.start()
	
	# Flip sprite based on direction
	if direction == -1:
		sprite.scale.x = -1

func _physics_process(delta):
	position.x += speed * direction * delta
	# Add floating up-down motion
	position.y += sin(Time.get_ticks_msec() * 0.01) * 2.0

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		destroy()
	elif body.is_in_group("ground") or body.is_in_group("wall"):
		# Create snow splash when hitting ground/wall
		create_snow_splash()
		destroy()

func _on_lifetime_timer_timeout():
	destroy()

func destroy():
	# Play break effect (you can add particles later)
	queue_free()

func create_snow_splash():
	# You can add a snow splash effect here later
	pass
