package components;

import luxe.Component;

import luxe.tween.Actuate;

class TileMovement extends Component {
	public var x:Int = -1;
	public var y:Int = -1;

	public function move_to(_x:Int, _y:Int, ?_animate:Bool=true) {
		var dest_tile = Level.get_tile(_x, _y);
		if (dest_tile == null) {
			return;
		}

		if (dest_tile.entities.length > 0) {
			// TODO: bump animation
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
}
