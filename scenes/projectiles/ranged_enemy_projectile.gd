extends Area2D


const SPEED: int = 750
var direction: Vector2 = Vector2.UP
var skip_player_collision: bool = false
var origin: Vector2


func _ready():
	$AudioStreamPlayer2D.play()
	origin = global_position


func _physics_process(delta):
	position += direction * SPEED * delta


# sends origin position instead of current position for knockback direction
func _on_body_entered(body):
	if "hit" in body:
		# only delete projectile if damage was dealt
		var initial_player_health: int = Globals.player_health
		body.hit(origin)
		if initial_player_health > Globals.player_health:
			queue_free()
	else:
		queue_free()


func _on_expire_timer_timeout():
	queue_free()
