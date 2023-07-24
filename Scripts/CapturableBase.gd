extends Area2D
class_name CapturableBase

signal base_captured(new_team)

export (Color) var neutral_color = Color(1, 1, 1)
export (Color) var player_color = Color(0.317647, 0.921569, 0.266667)
export (Color) var enemy_color = Color(0.854902, 0.129412, 0.129412)


var player_unit_count: int = 0
var enemy_unit_count: int = 0
var team_to_capture: int = Team.TeamName.NEUTRAL

onready var collision_shape = $CollisionShape2D
onready var team = $Team 
onready var capture_timer = $CaptureTimer
onready var sprite = $Sprite

func get_random_position_within_capture_radious() -> Vector2:
	var extents = collision_shape.shape.extents
	var top_left = collision_shape.global_position - (extents /2)
	var x = rand_range(top_left.x, top_left.x + extents.x)
	var y = rand_range(top_left.y, top_left.y + extents.y)
	return Vector2(x,y)

func _on_CapturableBase_body_entered(body):
	if body.has_method("get_team"):
		var body_team = body.get_team()
		if body_team == Team.TeamName.ENEMY:
			enemy_unit_count += 1
		elif body_team == Team.TeamName.PLAYER:
			player_unit_count +=1
	check_mayority()


func _on_CapturableBase_body_exited(body):
	if body.has_method("get_team"):
		var body_team = body.get_team()
		if body_team == Team.TeamName.ENEMY:
			enemy_unit_count -= 1
		elif body_team == Team.TeamName.PLAYER:
			player_unit_count -=1
	check_mayority()

func check_mayority():
	var mayority_team = get_team_mayority()
	if mayority_team == Team.TeamName.NEUTRAL:
		return
	elif mayority_team == team.team:
		#print("Owning team registered mayority, stoping capture clock")
		team_to_capture = Team.TeamName.NEUTRAL
		capture_timer.stop()
	else:
		#print("New team has mayority in base, starting countdown clock")
		team_to_capture = mayority_team
		capture_timer.start()
	

func get_team_mayority()->int:
	if enemy_unit_count == player_unit_count:
		return Team.TeamName.NEUTRAL
	elif enemy_unit_count > player_unit_count:
		return Team.TeamName.ENEMY
	else:
		return Team.TeamName.PLAYER

func set_team(new_team: int):
	self.team.team = new_team
	emit_signal("base_captured", new_team)
	match new_team:
		Team.TeamName.NEUTRAL:
			sprite.modulate = neutral_color
			return
		Team.TeamName.PLAYER:
			sprite.modulate = player_color
			return
		Team.TeamName.ENEMY:
			sprite.modulate = enemy_color
			return

func _on_CaptureTimer_timeout():
	set_team(team_to_capture)
