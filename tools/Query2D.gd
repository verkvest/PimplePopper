class_name Query2D
extends RefCounted

## Godot 4 physics queries. Protuberances are Area2D nodes, so bodies are ignored.


static func point(space: PhysicsDirectSpaceState2D, pos: Vector2, mask: int, max_results: int = 32) -> Array:
	var params := PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collision_mask = mask
	params.collide_with_areas = true
	params.collide_with_bodies = false
	return space.intersect_point(params, max_results)


static func ray(space: PhysicsDirectSpaceState2D, from: Vector2, to: Vector2, exclude: Array = []) -> Dictionary:
	var params := PhysicsRayQueryParameters2D.create(from, to)
	params.collision_mask = 0x7FFFFFFF
	params.collide_with_areas = true
	params.collide_with_bodies = false
	var rids: Array[RID] = []
	for item in exclude:
		if item is RID:
			rids.append(item)
		elif item is CollisionObject2D:
			rids.append(item.get_rid())
	params.exclude = rids
	return space.intersect_ray(params)
