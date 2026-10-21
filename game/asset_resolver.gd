class_name AssetResolver
extends Node
## CMP-asset-resolver boot hook for ACC.G1. Full manifest load is a later task.

signal boot_ready

const MANIFEST_PATH := "res://asset_manifest.json"


func preload_boot() -> void:
	call_deferred("_finish_boot")


func _finish_boot() -> void:
	if not FileAccess.file_exists(MANIFEST_PATH):
		push_warning("Boot manifest missing; continuing without Boot assets")
	boot_ready.emit()
