extends Node


var character: CharacterBody3D
var head: Node3D
var camera: Camera3D
var shape: Shape3D

signal stats_handler_ready(stats: PlayerStatsHandler)

var movement_handler: PlayerMovementHandler
var camera_handler: PlayerCameraHandler
var stats_handler: PlayerStatsHandler:
	set(value):
		stats_handler = value
		stats_handler_ready.emit(value)
