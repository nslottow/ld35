package components;

import luxe.Component;

import luxe.tween.Actuate;

import entities.PlayerUnit;

class TileMovement extends Component {
	public var x:Int = -1;
	public var y:Int = -1;

	public var tile:Level.Tile;

	public var pushable:Bool = false;
	public var walkable:Bool = false;

	override function ondestroy() {
		if (tile != null) {
			tile.entities.remove(entity);
		}
	}

	public function move_to(_x:Int, _y:Int, ?_animate:Bool=true) {
		var dest_tile = Level.get_tile(_x, _y);
		if (dest_tile == null || dest_tile.solid) {
			return;
		}

		if (dest_tile.entities.length > 0) {
			// TODO: bump animation

			var move_blocked = false;

			for (other_entity in dest_tile.entities) {
				// TODO: Better names for these events
				entity.events.fire('bumped_into', other_entity);
				other_entity.events.fire('bumped_by', entity);

				// TODO: This is a kind of confusing way to distinguish between walkable and not
				var other_movement:TileMovement = other_entity.get('tile_movement');
				if (other_movement == null || !other_movement.walkable) {
					move_blocked = true;
				}
			}

			if (move_blocked) {
				return;
			}
		}

		// Update the entity lists on the source and destination tiles
		var src_tile = Level.get_tile(x, y);
		if (src_tile != null) {
			src_tile.entities.remove(entity);
		}

		dest_tile.entities.push(entity);	
		tile = dest_tile;

		// Update our tile and world position	
		x = _x;
		y = _y;

		var dest_pos = Level.get_tile_pos(_x, _y);
		if (_animate) {
			Actuate.tween(pos, 0.13, {x: dest_pos.x, y: dest_pos.y});
		} else {
			pos.set_xy(dest_pos.x, dest_pos.y);
		}
	}

	public function move(dx:Int, dy:Int) {
		move_to(x + dx, y + dy, true);
	}
}
