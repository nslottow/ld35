package entities;

import luxe.Entity;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.Color;
import luxe.Log.*;
import luxe.tween.Actuate;

import components.*;


class UnitDispenser extends Sprite {
	var tile_movement:TileMovement;

	public override function new(?_options:luxe.options.SpriteOptions) {
		_options.color = new Color(1.0, 1.0, 1.0);
		_options.centered = false;

		super(_options);

		tile_movement = add(new TileMovement({name: 'tile_movement'}));

		events.listen('bumped_by', on_bumped_by);
	}

	function on_bumped_by(other:Entity) {
		if (Std.is(other, PlayerUnit)) {
			var other_unit:PlayerUnit = cast other;
			var other_tile = other_unit.tile_movement.tile;

			var tile = tile_movement.tile;

			var dx = tile.x - other_tile.x;
			var dy = tile.y - other_tile.y;

			var target_tile = tile;
			while (true) {
				target_tile = Level.get_tile(target_tile.x + dx, target_tile.y + dy);
				if (target_tile == null) {
					return;
				}
				if (target_tile.entities.length == 0) {
					// Create a new unit on this tile
					var new_unit:PlayerUnit = Level.create_entity(PlayerUnit, target_tile.x, target_tile.y);

					new_unit.pos.set_xy(pos.x, pos.y);
					var dest_pos = Level.get_tile_pos(target_tile.x, target_tile.y);
					Actuate.tween(new_unit.pos, 0.13, {x: dest_pos.x, y: dest_pos.y});
					return;
				}
			}
		}
	}
}
