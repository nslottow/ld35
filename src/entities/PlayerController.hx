package entities;

import luxe.Entity;
import luxe.Input;
import luxe.Log.*;

import components.TileMovement;

class PlayerController extends Entity {
	public static var instance:PlayerController;

	public var units:Array<PlayerUnit> = [];

	public override function new(?_options:luxe.options.EntityOptions) {
		super(_options);
		instance = this;
	}

	override function ondestroy() {
		instance = null;
	}

	override function onkeydown(e:KeyEvent) {
		// TODO: Make keys configurable
		var dx = 0;
		var dy = 0;

		switch (e.keycode) {
			case Key.left:
				dx = -1;
			case Key.right:
				dx = 1;
			case Key.up:
				dy = -1;
			case Key.down:
				dy = 1;
			default:
		}

		if (dx != 0 || dy != 0) {
			// Find any push moves and apply those first

			// TODO: This won't quite work if a pushable entity is sandwiched by two player units,
			// but we'll fix that later. The fix is just to build a list of all moves (including pushes)
			// before carrying out any.

			for (unit in units) {
				var tile_movement = unit.tile_movement;
				var dest_tile = Level.get_tile(tile_movement.x + dx, tile_movement.y + dy);
				if (dest_tile != null) {
					var push_chain:Array<TileMovement> = get_push_chain(dest_tile, dx, dy);

					// Try to apply pushes in the direction of movement
					while (true) {
						var to_push = push_chain.pop();
						if (to_push == null) {
							break;
						} else {
							to_push.move(dx, dy);
						}
					}
				}
			}

			// Sort moves along the axis of movement
			var to_move = units.copy();

			var sort_by_x = function(a:PlayerUnit, b:PlayerUnit):Int {
				return (a.tile_movement.x - b.tile_movement.x) * -dx;
			};

			var sort_by_y = function(a:PlayerUnit, b:PlayerUnit):Int {
				return (a.tile_movement.y - b.tile_movement.y) * -dy;
			};

			var sort_func = dx != 0 ? sort_by_x : sort_by_y;
			to_move.sort(sort_func);

			for (unit in to_move) {
				unit.tile_movement.move(dx, dy);
			}

			Level.update_tile_state();
			build_groups();
		}
	}

	public function build_groups() {
		// Check for entities falling into an abyss
		var group_id = 0;
		var unvisited_units = units.copy();
		for (unit in units) {
			if (unvisited_units.indexOf(unit) != -1) {
				unvisited_units.remove(unit);
				group_id++;

				var group:Array<PlayerUnit> = [unit];
				var grounded = !unit.tile_movement.tile.abyss; // is at least one unit in the group over solid ground?
				unit.group = group;
				unit.group_id = group_id;

				var frontier:Array<Level.Tile> = unit.tile_movement.tile.neighbors.copy();
				while (frontier.length > 0) {
					var tile = frontier.pop();
					if (tile != null && tile.active_unit != null && unvisited_units.indexOf(tile.active_unit) != -1) {
						unvisited_units.remove(tile.active_unit);

						group.push(tile.active_unit);
						tile.active_unit.group = group;
						tile.active_unit.group_id = group_id;

						if (!tile.abyss) {
							grounded = true;
						}

						for (n in tile.neighbors) {
							frontier.push(n);
						}
					}
				}

				if (!grounded) {
					for (u in group) {
						u.events.fire('entered_abyss');
					}
				}
			}
		}
	}

	function get_push_chain(start_tile:Level.Tile, dx:Int, dy:Int):Array<TileMovement> {
		// Attempt to push whatever is currently on the start tile and in all adjacent tiles in the direction of movement
		// i.e. DFS for last pushable thing
		// TODO: The naming in this algorithm could be more straight-forward

		var push_chain:Array<TileMovement> = [];
		var cur_tile = start_tile;

		while (cur_tile != null) {
			var pushed_cur_tile = false;
			for (entity in cur_tile.entities) {
				var push_target:TileMovement = entity.get('tile_movement');
				if (push_target != null && push_target.pushable) {
					push_chain.push(push_target);
					pushed_cur_tile = true;
				}
			}

			if (pushed_cur_tile) {
				cur_tile = Level.get_tile(cur_tile.x + dx, cur_tile.y + dy);
			} else {
				break;
			}
		}

		return push_chain;
	}
}

