package components;

import luxe.Component;

import luxe.tween.Actuate;

import entities.PlayerUnit;

class TileMovement extends Component {
	public var x:Int = -1;
	public var y:Int = -1;

	public var dest_tile:Level.Tile;

	public var pushable:Bool = false;

	public function move_to(_x:Int, _y:Int, ?_animate:Bool=true) {
		dest_tile = Level.get_tile(_x, _y);
		if (dest_tile == null || dest_tile.solid) {
			return;
		}

		if (dest_tile.entities.length > 0) {
			// TODO: bump animation
			for (other_entity in dest_tile.entities) {
				entity.events.fire('bumped_into', other_entity);
				other_entity.events.fire('bumped_by', entity);
			}

			return;
		}

		// Update the entity lists on the source and destination tiles
		var src_tile = Level.get_tile(x, y);
		if (src_tile != null) {
			src_tile.entities.remove(entity);
		}

		dest_tile.entities.push(entity);	

		// Update our tile and world position	
		x = _x;
		y = _y;

		var dest_pos = Level.get_tile_pos(_x, _y);
		if (_animate) {
			Actuate.tween(pos, 0.15, {x: dest_pos.x, y: dest_pos.y});
		} else {
			pos.set_xy(dest_pos.x, dest_pos.y);
		}
	}

	public function move(dx:Int, dy:Int) {
		move_to(x + dx, y + dy, true);
	}

	public function post_resolve_moves() {
		dest_tile = null;
	}
}
