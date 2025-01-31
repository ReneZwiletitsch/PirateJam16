extends Node

const how_to_play: Array[String] = [
	"Hover over a corpse and press C to resurrect!",
	"WASD to move",
	"LMB to attack",
	"use stairs to get to the next level",
]


var player_position = Vector2(40,40)
var current_player_hp := 0
var current_player_strenght := 0
var current_player_dex := 0


var max_attack_cooldown := 10.0
var basic_attack_angle := PI/4 #45°, taken in both directions so 90° total
var basic_character_range := 50
var necromancy_range := 250
var aggro_range := 150


var player_died = false
var game_lost := false


var current_character = null
var staff_instance = null


var curr_char_stats = [0,0] #also used for detecting first room
var all_ai_char_instances = []
var chars_for_boss_fight = []


var boss_hp := 10000
var boss_defeated := false


func player_damage(strenght):
	current_player_hp -= strenght
	if current_player_hp <=0:
		current_player_hp = 0
		player_died = true
	#print("player hp: ",current_player_hp)
	


func boss_damage(strenght):
	boss_hp -= strenght
	if boss_hp <=0:
		boss_hp = 0
		boss_defeated = true
	#print("boss hp: ",boss_hp)
