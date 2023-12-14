extends CharacterBody2D


# attack zone locations depending on which side being faced
const ATTACK_LEFT_POS: float = 0
const ATTACK_RIGHT_POS: float = 45
const SWIPE_LEFT_POS: float = -30
const SWIPE_RIGHT_POS: float = -15

const BASE_DASH_FORCE: int = 3
const BASE_SPEED: int = 200

var can_dodge: bool = true
var can_heal: bool = false
var is_attacking: bool = false
var is_dodging: bool = false
var is_moving: bool = false
var is_vulnerable: bool = true

var dash_force: int = 1
var knockback_dir: Vector2 = Vector2.ZERO
var knockback_force: int = 0


func _ready():
	# everything faces the right at start
	$AnimatedSprite2D.flip_h = true
	$AttackArea.position.x = ATTACK_RIGHT_POS
	$AttackArea/AnimatedSprite2D.flip_h = true
	$AttackArea/AnimatedSprite2D.position.x = SWIPE_RIGHT_POS
	$AttackArea/AnimatedSprite2D.visible = false


func _physics_process(_delta):

	Globals.player_pos = global_position
	
	# movement input
	var direction: Vector2
	var joystick_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	var dpad_direction: Vector2 = Input.get_vector("left_dpad", "right_dpad", "up_dpad", "down_dpad")
	
	# workaround for godot ignoring dpad input
	if dpad_direction != Vector2.ZERO:
		direction = dpad_direction
	else:
		direction = joystick_direction
	
	# flipping left/right
	if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("right_dpad"):
		$AnimatedSprite2D.flip_h = true
		$AttackArea/AnimatedSprite2D.flip_h = true
		$AttackArea.position.x = ATTACK_RIGHT_POS
		$AttackArea/AnimatedSprite2D.position.x = SWIPE_RIGHT_POS
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("left_dpad"):
		$AnimatedSprite2D.flip_h = false
		$AttackArea/AnimatedSprite2D.flip_h = false
		$AttackArea.position.x = ATTACK_LEFT_POS
		$AttackArea/AnimatedSprite2D.position.x = SWIPE_LEFT_POS
	
	# dashing logic
	if abs(get_position_delta().x) >= 0.5 or abs(get_position_delta().y) >= 0.5:
		is_moving = true
	else:
		is_moving = false
	if Input.is_action_just_pressed("dodge") && can_dodge && is_moving && Globals.player_control:
		is_dodging = true
		is_vulnerable = false
		dash_force = BASE_DASH_FORCE
		can_dodge = false
		$AttackArea/AnimatedSprite2D.visible = false
		$AnimationPlayer.play("dodge")
		$Sounds/DashSound.play(0.25)
		$GPUParticles2D.restart()
		$GPUParticles2D2.restart()
		$Timers/VulnerableTimer.start()
		$Timers/DashCooldownTimer.start()
		$Timers/DashDurationTimer.start()
	
	# final movement calculations
	if Globals.player_control:
		velocity = (direction * BASE_SPEED * dash_force) + (knockback_dir * knockback_force)
		move_and_slide()
	
	# move animation only when not attacking
	if $AnimationPlayer.current_animation == "attack":
		is_attacking = true
	else:
		is_attacking = false
	var is_animating_dodge: bool = $AnimationPlayer.current_animation == "dodge"
	if direction != Vector2.ZERO and not is_attacking and not is_animating_dodge:
		$AnimationPlayer.play("move")
	if direction == Vector2.ZERO and not is_attacking and not is_animating_dodge:
		$AnimationPlayer.stop()
	
	# attack function is called through the attack animation
	if Input.is_action_just_pressed("attack") and Globals.player_control:
		$AnimationPlayer.play("attack")


# during attack animation, checks for enemies in attack area, attacks only one
func attack():
	var targets = $AttackArea.get_overlapping_bodies()
	var projectiles = $AttackArea.get_overlapping_areas()
	for target in targets:
		if 'hit' in target:
			target.hit()
			break
		break
	for projectile in projectiles:
		if 'hit' in projectile:
			projectile.hit()
			break
		break


# when hit by enemy, different effects if dodged or hit
func hit(enemy_position):
	# getting hit while dodging
	if is_dodging and not is_vulnerable and can_heal:
		if Globals.player_health < Globals.HEALTH_MAX:
			Globals.player_health += 1
			$Sounds/HealthSound.play()
			$Label.show()
			can_heal = false
		elif Globals.player_health == Globals.HEALTH_MAX:
			$Label2.show()
	# getting hit normally
	if is_vulnerable:
		is_vulnerable = false
		$Timers/VulnerableTimer.start()
		$AnimatedSprite2D.material.set_shader_parameter("progress", 1)
		$Timers/ShaderTimer.start()
		$Sounds/HitSound.play(0.25)
		Globals.player_health -= 1
		knockback_dir = (Globals.player_pos - enemy_position).normalized()
		knockback_force = 400
		$Timers/KnockbackTimer.start()


func _on_animation_player_animation_finished(_attacking):
	$AnimationPlayer.play("move")


# attack zone monitoring left off until needed during attack animation
func _on_attack_area_body_entered(_body):
	pass


func _on_dash_cooldown_timer_timeout():
	can_dodge = true
	can_heal = true
	is_dodging = false
	$Label.hide()
	$Label2.hide()


func _on_dash_duration_timer_timeout():
	dash_force = 1
	velocity = Vector2.ZERO


func _on_knockback_timer_timeout():
	knockback_force = 0


func _on_shader_timer_timeout():
	$AnimatedSprite2D.material.set_shader_parameter("progress", 0)


func _on_vulnerable_timer_timeout():
	is_vulnerable = true
