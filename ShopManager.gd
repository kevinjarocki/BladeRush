extends Node2D

@export var money = 0



func _on_player_interacted(station):
	if station:
		print(station.owner.name)
	else:
		print("No station nearby")
