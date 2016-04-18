package entities;

import luxe.Entity;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.Color;
import luxe.Log.*;
import luxe.components.sprite.SpriteAnimation;

import luxe.tween.Actuate;

import components.*;

typedef PlayerUnitOptions = {
	> luxe.options.SpriteOptions,

	@:optional var active:Bool;
}

class PlayerUnit extends Sprite {
	public var controller(default, set):PlayerController;
	public var tile_movement:TileMovement;
	public var anim:SpriteAnimation;
	
	public static var active_color = new Color(1, 1, 1);
	public static var inactive_color = new Color(0.7, 0.4, 0.7);

	public var destructing(default, set):Bool = false;

	var falling:Bool = false;
	var fall_tween_target:Dynamic;

	public override function new(?_options:PlayerUnitOptions) {
		_options.texture = Luxe.resources.texture('assets/textures/cha_alien.png');
		_options.centered = false;

		super(_options);
		
		tile_movement = add(new TileMovement({name: 'tile_movement'}));

		{
			var anim_data = Luxe.resources.json('assets/animations/cha_alien.json').asset.json;
			anim = add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);
			anim.animation = 'inactive';
		}

		controller = def(_options.active, false) ? PlayerController.instance : null;

		events.listen('move.start', function(_) { anim.animation = 'move'; anim.play(); });
		events.listen('move.finish', on_move_finish);
		events.listen('bumped_by', on_bumped_by);
		events.listen('entered_abyss', on_entered_abyss);
	}

	override function ondestroy() {
		super.ondestroy();
		Actuate.stop(fall_tween_target);
		controller = null;
	}

	function on_move_finish(_) {
		if (!destructing) {
			anim.animation = 'active';
		}

		if (falling) {
			centered = true;
			pos.x += Level.tile_width * 0.5;
			pos.y += Level.tile_height * 0.5;
			fall_tween_target = size;	
			Actuate.tween(fall_tween_target, 0.23, {x: size.x * 0.1, y: size.y * 0.1})
				.ease(new luxe.tween.easing.Quad.QuadEaseOut());
			Luxe.timer.schedule(0.25, function() { 
				destroy();
			});
		}
	}

	function on_bumped_by(other:Entity) {
		if (controller == null && Std.is(other, PlayerUnit)) {
			var other_unit:PlayerUnit = cast other;
			if (!destructing) {
				controller = other_unit.controller;
			}
		}
	}

	function on_entered_abyss(abyss:Abyss) {
		destructing = true;
		falling = true;
	}

	public function set_controller(_controller:PlayerController) {
		if (_controller != null) {
			if (controller != _controller) {
				_controller.units.push(this);
			}
			color = active_color;
			anim.animation = 'active';
		} else {
			if (controller != null) {
				controller.units.remove(this);

				if (controller.units.length == 0) {
					trace('Game over!');
				} else {
					trace('Units left: ${controller.units.length}');


					Level.update_tile_state();
					if (PlayerController.instance != null) {
						PlayerController.instance.build_groups();
					}
					Level.check_level_complete();
				}
			}

			if (!destructing) {
				color = inactive_color;
			}
		}
		return controller = _controller;
	}

	public function set_destructing(_destructing:Bool) {
		if (_destructing) {
			controller = null;
			anim.animation = 'hurt';
			anim.play();
		}
		return destructing = _destructing;
	}
}

