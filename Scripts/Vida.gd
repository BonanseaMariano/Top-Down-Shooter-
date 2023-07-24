extends Node2D

export (int) var vida = 100 setget set_vida

func set_vida(nueva_vida: int):
	vida = clamp(nueva_vida, 0, 100)
