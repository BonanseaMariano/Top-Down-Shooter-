extends KinematicBody2D
class_name Player

signal player_health_changed(new_health)
signal died

export (int) var speed = 100

onready var collision_shape = $CollisionShape2D
onready var weapon_manager = $WeaponManager
onready var vida = $Vida
onready var team = $Team
onready var camera_transform = $CameraTransform

func _ready():
	weapon_manager.initialize(team.team)

func _physics_process(delta):
	var movimiento_direccion := Vector2.ZERO
	
	if Input.is_action_pressed("P1up"):
		movimiento_direccion.y = -1
	if Input.is_action_pressed("P1down"):
		movimiento_direccion.y = 1
	if Input.is_action_pressed("P1right"):
		movimiento_direccion.x = 1
	if Input.is_action_pressed("P1left"):
		movimiento_direccion.x = -1
	
	move_and_slide(movimiento_direccion.normalized() * speed)
	look_at(get_global_mouse_position())

func set_camera_transform(camera_path: NodePath):
	camera_transform.remote_path = camera_path

func get_team() -> int:
	return team.team

func handle_hit():
	vida.vida -=20
	emit_signal("player_health_changed", vida.vida)
	if vida.vida <= 0:
		die()

func die():
	emit_signal("died")
	queue_free()
 

