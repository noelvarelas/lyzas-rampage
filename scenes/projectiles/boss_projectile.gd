extends Area2D


const BASE_SPEED: int = 400
var direction: Vector2 = Vector2.UP
var is_reflected: bool = false
var origin: Vector2


func _ready():
	origin = global_position
	$AudioStreamPlayer.play()
	$AnimationPlayer.play("idle")


func _physics_process(delta):
	position += direction * BASE_SPEED * delta


# different behavior depending on if reflected by player
func _on_body_entered(body):
	if "hit" in body and not is_reflected:
		# only delete projectile if damage was dealt
		var initial_player_health: int = Globals.player_health
		body.hit(origin)
		if initial_player_health > Globals.player_health:
			queue_free()
	elif "hit" in body and is_reflected:
		body.hit()
		queue_free()


func hit():
	# go opposite direction when reflected by player
	direction = direction * -1
	$AnimatedSprite2D.rotation_degrees = 270
	$Timers/CollisionSwap.start()


func _on_expire_timer_timeout():
	queue_free()


# disable collision with player when reflected
func _on_collision_swap_timeout():
	self.set_collision_mask_value(1, false)
	self.set_collision_mask_value(5, false)
	self.set_collision_mask_value(2, true)
	is_reflected = true
