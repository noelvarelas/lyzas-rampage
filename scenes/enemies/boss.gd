extends CharacterBody2D


var is_alive: bool = true
var is_getting_hit: bool = false
var is_near_player: bool = false
var starting_position: Vector2


# sent to level scene to spawn projectile
signal boss_projectile(pos, direction)
# sent to game_manager to toggle boss fight music
signal boss_fight_started


func _ready():
	starting_position = global_position
	$AnimatedSprite2D.visible = true
	$ExplosionSprite.visible = false


func _physics_process(_delta):
	# shooting logic
	if is_near_player and is_alive and not is_getting_hit:
		$AnimationPlayer.play('attack')
	elif not is_getting_hit and is_alive:
		$AnimationPlayer.play('idle')


func hit():
	
	# hit sound + flash sprite + blood particles
	is_getting_hit = true
	Globals.boss_health -= 1
	$Sounds/HitSound.play(0.25)
	$AnimatedSprite2D.material.set_shader_parameter("progress", 1)
	$Timers/ShaderTimer.start()
	$GPUParticles2D.restart()
	
	# death animation interrupts normal hit animation
	if Globals.boss_health <= 0:
		is_alive = false
		$Sounds/DeathSound.stop()
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimationPlayer.play("death")
		await $AnimationPlayer.animation_finished
		get_tree().change_scene_to_file("res://scenes/user_interface/ending.tscn")
	elif Globals.boss_health > 0:
		$AnimationPlayer.play("hit")
		await $AnimationPlayer.animation_finished
		is_getting_hit = false


# sends signal that instantiates projectile in level scene
func shoot():
	var pos: Vector2 = global_position
	var direction: Vector2 = (Globals.player_pos - position).normalized()
	if is_alive:
		boss_projectile.emit(pos, direction)


func _on_attack_area_body_entered(_body):
	is_near_player = true
	boss_fight_started.emit()


func _on_attack_area_body_exited(_body):
	is_near_player = false


func _on_shader_timer_timeout():
	$AnimatedSprite2D.material.set_shader_parameter("progress", 0)
