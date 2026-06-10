extends Node


var character: CharacterBody3D
var head: Node3D
var camera: Camera3D
var shape: CapsuleShape3D

signal stats_handler_ready(stats: PlayerStatsHandler)

var MovementHandler: PlayerMovementHandler
var CameraHandler: PlayerCameraHandler
var StatsHandler: PlayerStatsHandler:
	set(value):
		StatsHandler = value
		stats_handler_ready.emit(value)
