extends CharacterBody2D


const BASE_SPEED: int = 225
var activated: bool = false
var attacking: bool = false
var health: int = 3
var is_alive: bool = true
var knockback_force: int = 0
var speed_multiplier: float = 1


func _ready():
	$AnimatedAttackSprite2D.visible = false
	$AnimationPlayer.play("move")


func _physics_process(_delta):
	
	if activated:
		# determine direction to face
		if Globals.player_pos.x < global_position.x:
			$AnimatedSprite2D.flip_h = false
			$AnimatedAttackSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true
			$AnimatedAttackSprite2D.flip_h = true
		
		# figure out the direction to the next nav point, slight randomization
		var next_path_pos: Vector2 = $NavigationAgent2D.get_next_path_position()
		if randi_range(0, 1) == 0:
			$NavigationAgent2D.target_position = $NavigationAgent2D.target_position + Vector2((randf_range(-10, 10)), (randf_range(-10, 10)))
		var direction: Vector2 = (next_path_pos - global_position).normalized()
		
		# applies knockback which is temporarily applied by hit()
		var knockback_dir = (global_position - Globals.player_pos).normalized()
		velocity = (direction * BASE_SPEED * speed_multiplier) + (knockback_dir * knockback_force)
		move_and_slide()
	
	# allows knockback on death
	if not is_alive:
		var knockback_dir = (global_position - Globals.player_pos).normalized()
		velocity = (knockback_dir * knockback_force)
		move_and_slide()
	
	
	# toggled on while in attack area
	if attacking:
		if $Areas/AttackArea.has_overlapping_bodies():
			speed_multiplier = 0
			$AnimationPlayer.play("attack")
			await $AnimationPlayer.animation_finished
			$AnimationPlayer.stop()


func attack():
	var targets = $Areas/DamageArea.get_overlapping_bodies()
	for target in targets:
		if 'hit' in target and is_alive:
			target.hit(global_position)


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
		activated = false
		$AnimatedAttackSprite2D.visible = false
		$Areas/AttackArea/CollisionShape2D.set_deferred("disabled", true)
#		$CollisionShape2D.set_deferred("disabled", true)
		$AnimationPlayer.play("death")
		$AnimatedSprite2D.rotation_degrees = 90
		$Sounds/DeathSound.play()
		await $Sounds/DeathSound.finished
		queue_free()


# resets sprites to normal after hit flash
func _on_hit_timer_timeout():
	$AnimatedSprite2D.material.set_shader_parameter("progress", 0)


# adjust timer for nav update rate
func _on_nav_timer_timeout():
	$NavigationAgent2D.target_position = Globals.player_pos


# enables attacks in process function
func _on_attack_area_body_entered(_body):
	attacking = true


# resets from attacking to chasing
func _on_attack_area_body_exited(_body):
	attacking = false
	await $AnimationPlayer.animation_finished
	speed_multiplier = 1
	$AnimationPlayer.play("charge")


# used during attack function
func _on_damage_area_body_entered(_body):
	pass


# initial activation, stays active until death
func _on_notice_area_body_entered(_body):
	if not activated:
		$AnimationPlayer.play("notice")
		await $AnimationPlayer.animation_finished
		activated = true
		$AnimationPlayer.play("charge")


# ends the effects of knockback
func _on_knockback_timer_timeout():
	knockback_force = 0

