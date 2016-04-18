package states;

import luxe.Input;
import luxe.Color;
import luxe.Vector;

import luxe.Parcel;
import luxe.ParcelProgress;

import luxe.Sprite;
import phoenix.Texture;
import luxe.components.sprite.SpriteAnimation;

class AnimationTest extends luxe.States.State {

	override function onenter<T>(_:T) {
		var parcel = new Parcel({
            jsons: [
				{ id:'assets/animations/cha_alien.json' },
				{ id:'assets/animations/cha_mib.json' }
			],
            textures: [
                { id: 'assets/textures/cha_alien.png' },
                { id: 'assets/textures/cha_mib.png' }
            ],
			oncomplete: on_loaded
        });

		parcel.load();
	}

	function on_loaded(_) {
		var sprite_size = new Vector(64, 64);
		var margin = 20.0;

		// Alien active
		{
			var texture = Luxe.resources.texture('assets/textures/cha_alien.png');
			var sprite = new Sprite({
				pos: new Vector(margin, margin),
				texture: texture,
				size: sprite_size,
				color: new Color(0.7, 0.4, 0.7),
				centered: false
			});
			var anim_data = Luxe.resources.json('assets/animations/cha_alien.json').asset.json;
			var anim = sprite.add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);

			anim.animation = 'inactive';
			anim.play();
		}

		// Alien active
		{
			var texture = Luxe.resources.texture('assets/textures/cha_alien.png');
			var sprite = new Sprite({
				pos: new Vector(sprite_size.x * 1 + margin, margin),
				texture: texture,
				size: sprite_size,
				centered: false
			});
			var anim_data = Luxe.resources.json('assets/animations/cha_alien.json').asset.json;
			var anim = sprite.add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);

			anim.animation = 'active';
			anim.play();
		}


		// Alien move
		{
			var texture = Luxe.resources.texture('assets/textures/cha_alien.png');
			var sprite = new Sprite({
				pos: new Vector(sprite_size.x * 2 + margin, margin),
				texture: texture,
				size: sprite_size,
				centered: false
			});
			var anim_data = Luxe.resources.json('assets/animations/cha_alien.json').asset.json;
			var anim = sprite.add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);

			anim.animation = 'move';
			anim.play();
		}

		// Alien hurt
		{
			var texture = Luxe.resources.texture('assets/textures/cha_alien.png');
			var sprite = new Sprite({
				pos: new Vector(sprite_size.x * 3 + margin, margin),
				texture: texture,
				size: sprite_size,
				centered: false
			});
			var anim_data = Luxe.resources.json('assets/animations/cha_alien.json').asset.json;
			var anim = sprite.add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);

			anim.animation = 'hurt';
			anim.play();
		}

		// Gunman down
		{
			var texture = Luxe.resources.texture('assets/textures/cha_mib.png');
			var sprite = new Sprite({
				pos: new Vector(sprite_size.x * 0 + margin, sprite_size.y * 1 + margin * 2),
				texture: texture,
				size: sprite_size,
				centered: false
			});
			var anim_data = Luxe.resources.json('assets/animations/cha_mib.json').asset.json;
			var anim = sprite.add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);

			anim.animation = 'attack_down';
			anim.play();
		}

		// Gunman left
		{
			var texture = Luxe.resources.texture('assets/textures/cha_mib.png');
			var sprite = new Sprite({
				pos: new Vector(sprite_size.x * 1 + margin, sprite_size.y * 1 + margin * 2),
				texture: texture,
				size: sprite_size,
				centered: false
			});
			var anim_data = Luxe.resources.json('assets/animations/cha_mib.json').asset.json;
			var anim = sprite.add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);

			anim.animation = 'attack_left';
			anim.play();
		}

		// Gunman right
		{
			var texture = Luxe.resources.texture('assets/textures/cha_mib.png');
			var sprite = new Sprite({
				pos: new Vector(sprite_size.x * 2 + margin, sprite_size.y * 1 + margin * 2),
				texture: texture,
				size: sprite_size,
				centered: false
			});
			var anim_data = Luxe.resources.json('assets/animations/cha_mib.json').asset.json;
			var anim = sprite.add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);

			anim.animation = 'attack_right';
			anim.play();
		}

		// Gunman up
		{
			var texture = Luxe.resources.texture('assets/textures/cha_mib.png');
			var sprite = new Sprite({
				pos: new Vector(sprite_size.x * 3 + margin, sprite_size.y * 1 + margin * 2),
				texture: texture,
				size: sprite_size,
				centered: false
			});
			var anim_data = Luxe.resources.json('assets/animations/cha_mib.json').asset.json;
			var anim = sprite.add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);

			anim.animation = 'attack_up';
			anim.play();
		}

		// Gunman dead
		{
			var texture = Luxe.resources.texture('assets/textures/cha_mib.png');
			var sprite = new Sprite({
				pos: new Vector(sprite_size.x * 4 + margin, sprite_size.y * 1 + margin * 2),
				texture: texture,
				size: sprite_size,
				centered: false
			});
			var anim_data = Luxe.resources.json('assets/animations/cha_mib.json').asset.json;
			var anim = sprite.add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);

			anim.animation = 'dead';
			anim.play();
		}

		// Gunman plasma
		{
			var texture = Luxe.resources.texture('assets/textures/cha_mib.png');
			var sprite = new Sprite({
				pos: new Vector(sprite_size.x * 0 + margin, sprite_size.y * 2 + margin * 3),
				texture: texture,
				size: sprite_size,
				centered: false
			});
			var anim_data = Luxe.resources.json('assets/animations/cha_mib.json').asset.json;
			var anim = sprite.add(new SpriteAnimation({ name: 'anim' }));
			anim.add_from_json_object(anim_data);

			anim.animation = 'plasma';
			anim.play();
		}

	}

	override function onleave<T>(_:T) {
		Luxe.scene.empty();
	}
}

