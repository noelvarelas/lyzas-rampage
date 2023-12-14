extends Node2D


signal screen_just_cleared


var projectile_scene: PackedScene = preload("res://scenes/projectiles/ranged_enemy_projectile.tscn")
var boss_projectile_scene: PackedScene = preload("res://scenes/projectiles/boss_projectile.tscn")
var active_screen: int = 1
var camera_limit_right: int = 1280


func _ready():
	$Player/Camera2D.limit_right = camera_limit_right

# screen advancement, remove gate and extend camera limit
func _physics_process(_delta):
	if active_screen == 1:
		var enemies = $"EnemiesScreen1".get_child_count()
		if enemies == 0:
			$Background/LevelBoundaries/Gate1.set_deferred("disabled", true)
			camera_limit_right = 2560
			$Player/Camera2D.limit_right = camera_limit_right
			active_screen = 2
			emit_signal("screen_just_cleared")
	elif active_screen == 2:
		var enemies = $"EnemiesScreen2".get_child_count()
		if enemies == 0:
			$Background/LevelBoundaries/Gate2.set_deferred("disabled", true)
			camera_limit_right = 3840
			$Player/Camera2D.limit_right = camera_limit_right
			active_screen = 3
			emit_signal("screen_just_cleared")
	elif active_screen == 3:
		var enemies = $"EnemiesScreen3".get_child_count()
		if enemies == 0:
			$Background/LevelBoundaries/Gate3.set_deferred("disabled", true)
			camera_limit_right = 5120
			$Player/Camera2D.limit_right = camera_limit_right
			active_screen = 4
			emit_signal("screen_just_cleared")


# ranged enemy projectile creation
func create_projectile(pos,direction):
	var projectile = projectile_scene.instantiate() as Area2D
	projectile.position = pos
	projectile.rotation_degrees = rad_to_deg(direction.angle()) + 90
	projectile.direction = direction
	$Projectiles.add_child(projectile)


# boss projectile creation
func create_boss_projectile(pos,direction):
	var projectile = boss_projectile_scene.instantiate() as Area2D
	projectile.position = pos
	projectile.rotation_degrees = rad_to_deg(direction.angle()) + 90
	projectile.direction = direction
	$Projectiles.add_child(projectile)


# receives signal from ranged enemy scene
func _on_ranged_enemy_projectile(pos, direction):
	create_projectile(pos, direction)


# receives signal from boss enemy scene
func _on_boss_boss_projectile(pos, direction):
	create_boss_projectile(pos, direction)
