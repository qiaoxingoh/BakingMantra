# frost_berry.gd
extends Area2D

@export var item_name: String = "frost_berry"
@export var respawn_time: float = 3.0  # Time to respawn if needed

func _on_body_entered(body):
	if body.is_in_group("player"):
		collect(body)

func collect(player):
	# Add to player's inventory
	if player.has_method("collect_item"):
		player.collect_item(item_name)
	
	# Play collection sound/effect
	$CollectionSound.play()
	$Sprite2D.hide()
	$CollisionShape2D.disabled = true
	
	# If you want berries to respawn after some time:
	await get_tree().create_timer(respawn_time).timeout
	$Sprite2D.show()
	$CollisionShape2D.disabled = false
	
	# If you DON'T want respawning, use this instead:
	# queue_free()  # Remove permanently
