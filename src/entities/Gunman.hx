package entities;

import luxe.Entity;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.Color;
import luxe.Log.*;
import luxe.tween.Actuate;
import luxe.tween.easing.Sine;
import luxe.tween.easing.Linear;
import luxe.components.sprite.SpriteAnimation;

import components.*;

typedef GunmanOptions = {
	> luxe.options.SpriteOptions,

	@:optional var face:String;
}

@:keep class Gunman extends Sprite {
	var tile_movement:TileMovement;
	var anim:SpriteAnimation;
	var face:String;

	var evt_tick:String;

	public override function new(?_options:GunmanOptions) {
		_options.texture = Luxe.resources.texture('assets/textures/cha_mib.png');
		_options.centered = false;
		_options.depth = 1;

		super(_options);

		tile_movement = add(new TileMovement({name: 'tile_movement'}));
		tile_movement.walkable = true;

		{
			face = def(_options.face, 'right');
		}

		{
			var anim_data = Luxe.resources.json('assets/animations/cha_mib.json').asset.json;
			anim = add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);
			anim.animation = 'attack_$face';
		}

		evt_tick = Level.on('tick', tick);
		events.listen('bumped_by', on_bumped_by);
	}

	override function ondestroy() {
		super.ondestroy();
		anim.stop();
		Level.off(evt_tick);
	}

	function on_bumped_by(other:Entity) {
		if (Std.is(other, PlayerUnit)) {
			// Deactivate this gunman so it doesn't shoot on the tick it dies
			active = false;

			anim.animation = 'dead';
			remove('tile_movement');
			Sfx.play_eat();
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

					Sfx.play_rifle();

					// TODO: Animate this properly
					// Create a bullet sprite that flies from us to the player
					{
						var hw = Level.tile_width * 0.5;
						var hh = Level.tile_height * 0.5;

						var bullet = new Sprite({
							pos: new Vector(pos.x + hw, pos.y + hh),
							size: new Vector(size.x * 1.2, size.y * 1.2),
							texture: Luxe.resources.texture('assets/textures/cha_mib.png'),
							depth: 300
						});

						var anim_data = Luxe.resources.json('assets/animations/cha_mib.json').asset.json;
						var bullet_anim = bullet.add(new SpriteAnimation({ name: 'anim' }));
						bullet_anim.add_from_json_object(anim_data);
						bullet_anim.animation = 'plasma';

						switch (face) {
							case 'left':
								bullet.flipx = true;
							case 'up':
								bullet.radians = -Math.PI * 0.5;
							case 'down':
								bullet.radians = Math.PI * 0.5;
						}

						var dest_tile = active_unit.tile_movement.tile;
						var dest_pos = Level.get_tile_pos(dest_tile.x, dest_tile.y);
						dest_pos.x += hw;
						dest_pos.y += hh;
						var delta_pos = Vector.Subtract(pos, dest_pos);
						delta_pos.normalize();
						delta_pos.x *= hw;
						delta_pos.y *= hh;
						dest_pos.add(delta_pos);

						var src_tile = tile_movement.tile;
						var tile_dx = Math.abs(dest_tile.x - src_tile.x);
						var tile_dy = Math.abs(dest_tile.y - src_tile.y);
						var tile_distance = Math.max(tile_dx, tile_dy);
						var delay = tile_distance * 0.05;
						var tween = Actuate.tween(bullet.pos, delay, {x: dest_pos.x, y: dest_pos.y});
						tween.ease(new SineEaseIn());
						Sfx.play_splat(delay * 0.9);

						delay += 0.03;
						Luxe.timer.schedule(delay, function() {
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
