extends Node2D

signal nextDayPressed
signal speedInc
signal coolingDec
signal heatInc

func endDay(day, money):
	visible = true
	$Control/Info.text = "Finished day: " + str(day) + "\n"
	#print(self.owner.heatingMod)

func _on_next_day_pressed():
	visible = false
	nextDayPressed.emit()

func _on_player_speed_inc_pressed():
	speedInc.emit()

func _on_cooling_rate_dec_pressed():
	coolingDec.emit()

func _on_heat_rate_inc_pressed():
	heatInc.emit()
