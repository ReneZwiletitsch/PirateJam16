extends Node



const intro_story_and_tutorial: Array[String] = [
	"W ... what happened?",
	"Why can't I move?",
	"Wait, am I stuck in my Staff???",
	"Where is my body?",
	"Tutorial: Perform necromancy on corpses to use them to transport you",
	"But be careful, you are not in full control over it!",
	"Hover over a corpse and press C to resurrect it!",
	"While controlling a corpse use WASD to move and LMB to attack",
	"use stairs to get to enter the next level",
]

const dialogue_necromancer_revived: Array[String] = [
	"Finally back in my body",	
]

const dialogue_boss_visible: Array[String] = [
	"Oh **** he's still here",	
]

const dialogue_summon_help: Array[String] = [
	"good thing i brought backup!",
]

const dialogue_bossfight_starts: Array[String] =[
	"You won't get me down a second time!",
]

const dialogue_second_phase: Array[String] =[
	"Guess I'll have to do this myself!"
]
	



var player_position = Vector2(165,118)
var current_player_hp := 0
var current_player_strenght := 0
var current_player_dex := 0


var max_attack_cooldown := 10.0
var basic_attack_angle := PI/4 #45°, taken in both directions so 90° total
var basic_character_range := 50
var necromancy_range := 250
var aggro_range := 150


var player_died = false


var current_character = null
var staff_instance = null


var curr_char_stats = [0,0] #also used for detecting first room
var all_ai_char_instances = []
var chars_for_boss_fight = []


var boss_hp := 10000
var boss_defeated := false

var in_boss_scene := false

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
