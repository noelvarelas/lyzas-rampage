extends CharacterBody2D


var health: int = 3
var is_alive: bool = true
var is_near_player: bool = false
var knockback_force: int = 0
var starting_position: Vector2


# sent to level scene to spawn projectile
signal projectile(pos, direction)


func _ready():
	starting_position = global_position
	$AnimatedAttackLeftSprite2D.visible = false
	$AnimatedAttackRightSprite2D.visible = false


func _physics_process(_delta):
	
	# knockback when hit
	var knockback_dir = (global_position - Globals.player_pos).normalized()
	velocity = knockback_dir * knockback_force
	move_and_slide()
	
	# shooting logic
	if is_near_player and is_alive:
		var current_attack_animation: String = 'attack_left'
		# if player is to the left
		if Globals.player_pos.x <= global_position.x:
			$AnimatedSprite2D.flip_h = false
			$AnimatedAttackRightSprite2D.visible = false
		# if player is to the right
		elif Globals.player_pos.x > global_position.x:
			$AnimatedSprite2D.flip_h = true
			$AnimatedAttackLeftSprite2D.visible = false
			current_attack_animation = 'attack_right'
		$AnimationPlayer.play(current_attack_animation)
	elif not is_near_player and is_alive:
		$AnimationPlayer.play('idle')
		$AnimatedAttackLeftSprite2D.visible = false
		$AnimatedAttackRightSprite2D.visible = false

func hit():
	
	health -= 1
	
	# knockback toggle on a timer
	knockback_force = 400
	$Timers/KnockbackTimer.start()
	
	# hit sound + flash sprite + blood particles
	$Sounds/HitSound.play(0.25)
	$AnimatedSprite2D.material.set_shader_parameter("progress", 1)
	$Timers/ShaderTimer.start()
	$GPUParticles2D.restart()
	
	# removes sprite and collision while death sound finishes
	if health <= 0:
		is_alive = false
#		$CollisionShape2D.set_deferred("disabled", true)
		$AnimationPlayer.stop()
		$AnimationPlayer.play("death")
		$AnimatedSprite2D.rotation_degrees = 45
		$Sounds/DeathSound.play()
		await $Sounds/DeathSound.finished
		queue_free()


# sends signal that instantiates projectile in level scene
func shoot():
	var pos: Vector2 = global_position
	var direction: Vector2 = (Globals.player_pos - position).normalized()
	if is_alive:
		projectile.emit(pos, direction)


func _on_attack_area_body_entered(_body):
	is_near_player = true


func _on_attack_area_body_exited(_body):
	is_near_player = false


# ends the effects of knockback
func _on_knockback_timer_timeout():
	knockback_force = 0


# resets sprites to normal after hit flash
func _on_shader_timer_timeout():
	$AnimatedSprite2D.material.set_shader_parameter("progress", 0)
