extends Node2D

var heatingMod = 0
var moneyPrevTurn = 0
var moneyEarned = 0

signal nextDayPressed
signal speedInc
signal coolingDec
signal heatInc

func _process(delta):
	$Control/PlayerSpeedInc.text = "Increase Player Walk Speed; \nLevel: " + str(owner.playerSpeedModInc) + "/10 Costs: " + str(owner.playerSpeedModCost[owner.playerSpeedModInc]) + "G"
	$Control/CoolingRateDec.text = "Decrease Cooling Rate; \nLevel: " + str(owner.coolingModInc) + "/10 Costs: " + str(owner.coolingModCost[owner.coolingModInc]) + "G"
	$Control/HeatRateInc.text = "Increase Heating Rate; \nLevel: " + str(owner.heatingModInc) + "/10 Costs: " + str(owner.heatingModCost[owner.heatingModInc]) + "G"
	$Control/Info.text = "Finished Day: " + str(owner.day) + "\nGold Earned: " + str(moneyEarned) + "G\nGold: " + str(owner.money) + "G"
	$Control/AutoIngot.text = "Auto Molmol: " + str(owner.autoMolmol) + "\nCosts: " + str(owner.autoMolmolCost) + "G"

func endDay(day, money):
	visible = true
	moneyEarned = owner.money - moneyPrevTurn

func _on_next_day_pressed():
	visible = false
	moneyPrevTurn = owner.money
	nextDayPressed.emit()

func _on_player_speed_inc_pressed():
	if owner.playerSpeedModInc < 10:
		speedInc.emit()

func _on_cooling_rate_dec_pressed():
	if owner.coolingModInc < 10:
		coolingDec.emit()

func _on_heat_rate_inc_pressed():
	if owner.heatingModInc < 10:
		heatInc.emit()

func _on_auto_ingot_pressed():
	if !owner.autoMolmol and owner.money >= owner.autoMolmolCost:
		owner.money -= owner.autoMolmolCost
		owner.autoMolmol = true
