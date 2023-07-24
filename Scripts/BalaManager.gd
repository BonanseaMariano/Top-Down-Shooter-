extends Node2D

func manejo_bala_disparada(bala: Bala, team: int, position: Vector2, direction: Vector2):
	add_child(bala)
	bala.team = team
	bala.global_position = position
	bala.set_direction(direction)
