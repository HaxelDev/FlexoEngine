import flexo.Flexo;
import flexo.Sprite;
import flexo.KeyCode;

class Main extends Flexo {
    public function new() {
        super(800, 600, "My Game");
    }

    override function render() {
        var sprite:Sprite = new Sprite();
        sprite.loadImage("assets/robot.png", 32, 32, true);
        sprite.addAnimation("sigma", [0]);
        sprite.playAnimation("sigma", true);
        sprite.setPosition(100, 100);
        sprite.setScale(2.0, 2.0);
        addSprite(sprite);

        super.render();
    }

    override function update() {
        super.update();
    }

    override function handleEvents() {
        if (Flexo.isKeyDown(KeyCode.LEFT)) {
            trace("jajco");
        } else if (Flexo.isKeyDown(KeyCode.RIGHT)) {
            trace("srajco");
        }  
        super.handleEvents();
    }

    static function main() {
        new Main();
    }
}
