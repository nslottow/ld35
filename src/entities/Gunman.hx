package entities;

import luxe.Entity;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.Color;
import luxe.Log.*;
import luxe.tween.Actuate;

import components.*;

typedef GunmanOptions = {
	> luxe.options.SpriteOptions,

	@:optional var face:String;
}

@:keep class Gunman extends Sprite {
	var tile_movement:TileMovement;
	var face:String;
	var facing_text:Text;

	var evt_tick:String;

	public override function new(?_options:GunmanOptions) {
		_options.color = new Color(1.0, 1.0, 0.2, 0.8);
		_options.centered = false;

		super(_options);

		tile_movement = add(new TileMovement({name: 'tile_movement'}));
		tile_movement.walkable = true;

		face = def(_options.face, 'right');

		facing_text = new Text({
			point_size: 12,
			parent: this,
			align: TextAlign.center,
			align_vertical: TextAlign.center,
			pos: new Vector(size.x * 0.5, size.y * 0.5),
			depth: 200,
			text: face
		});

		evt_tick = Level.on('tick', tick);
		events.listen('bumped_by', on_bumped_by);
	}

	override function ondestroy() {
		super.ondestroy();
		Level.off(evt_tick);
	}

	function on_bumped_by(other:Entity) {
		if (Std.is(other, PlayerUnit)) {
			// Deactivate this gunman so it doesn't shoot on the tick it dies
			active = false;

			// TODO: destroy this after the current tick properly
			Luxe.timer.schedule(0.1, function() {
				destroy();
			});
		}
	}

	function tick(_) {
		if (!active) {
			return;
		}

		var dx = 0;
		var dy = 0;

		switch (face) {
			case 'right':
				dx = 1;
			case 'up':
				dy = -1;
			case 'left':
				dx = -1;
			case 'down':
				dy = 1;
			default:
				trace('warning: Gunman has invalid "face" state: $face');
		}

		if (dx != 0 || dy != 0) {
			var tile = tile_movement.tile;
			while (true) {
				tile = Level.get_tile(tile.x + dx, tile.y + dy);
				if (tile == null || tile.solid) {
					//trace('gunman not shooting cause it saw solid or null tile');
					return;
				}

				for (entity in tile.entities) {
					var tile_movement = entity.get('tile_movement');
					if (!tile_movement.walkable && !Std.is(entity, PlayerUnit)) {
						//trace('gunman not shooting cause it saw unwalkable tile');
						return;
					}

					if (Std.is(entity, Gunman)) {
						//trace('gunman not shooting cause it saw gunman');
						return;
					}
				}

				var active_unit = tile.active_unit;
				if (active_unit != null) {
					active_unit.destructing = true;
					// TODO: Animate this properly
					// Create a bullet sprite that flies from us to the player
					{
						var hw = Level.tile_width * 0.5;
						var hh = Level.tile_height * 0.5;

						var bullet = new Sprite({
							pos: new Vector(pos.x + hw, pos.y + hh),
							size: new Vector(size.x * 0.5, size.y * 0.5),
							color: new Color(1, 0, 1),
							depth: 300
						});


						var dest_tile = active_unit.tile_movement.tile;
						var dest_pos = Level.get_tile_pos(dest_tile.x, dest_tile.y);
						dest_pos.x += hw;
						dest_pos.y += hh;
						Actuate.tween(bullet.pos, 0.15, {x: dest_pos.x, y: dest_pos.y});
						Luxe.timer.schedule(0.2, function() {
							bullet.destroy();
							active_unit.destroy();
						});
					}
					return;
				}
			}
		}
	}
}
