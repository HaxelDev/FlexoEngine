import flexo.Flexo;
import flexo.Sprite;

class Main extends Flexo {
    public function new() {
        super(800, 600, "My Game");
    }

    override function render() {
        var sprite:Sprite = new Sprite();
        sprite.loadImage("assets/robot.png", 32, 32);
        sprite.addAnimation("sigma", [0, 1, 2, 3]);
        sprite.playAnimation("sigma", true);
        sprite.setPosition(100, 100);
        sprite.setScale(2.0, 2.0);
        addSprite(sprite);

        super.render();
    }

    static function main() {
        new Main();
    }
}
