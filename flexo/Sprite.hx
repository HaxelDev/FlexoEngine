package flexo;

import sdl.SDL;
import sdl.Surface;
import sdl.Texture;
import sdl.Image;

class Sprite {
    public var texture:Texture;
    public var textureSize:Point;
    public var position:Point;
    public var scale:FPoint;
    public var animations:Map<String, Array<Int>>;
    public var currentAnimation:String;
    public var currentFrame:Int;
    public var frameWidth:Int;
    public var frameHeight:Int;
    public var isAnimating:Bool;

    public function new() {
        position = Point.create(0, 0);
        scale = FPoint.create(1, 1);
        animations = new Map<String, Array<Int>>();
        currentAnimation = "";
        currentFrame = 0;
        frameWidth = 0;
        frameHeight = 0;
        isAnimating = false;
    }

    public function loadImage(path:String, frameWidth:Int, frameHeight:Int) {
        this.frameWidth = frameWidth;
        this.frameHeight = frameHeight;

        var surface:Surface = Image.load(path);
        if (surface == null) {
            Sys.println("Failed to load image: " + path);
            return;
        }

        texture = SDL.createTextureFromSurface(Flexo.renderer, surface);
        if (texture == null) {
            Sys.println("Failed to create texture from image: " + path);
            return;
        }

        textureSize = SDL.getTextureSize(texture);
        SDL.freeSurface(surface);
    }

    public function addAnimation(name:String, frames:Array<Int>) {
        animations.set(name, frames);
    }

    public function playAnimation(name:String, loop:Bool = false) {
        if (!animations.exists(name)) {
            Sys.println("Animation '" + name + "' does not exist.");
            return;
        }

        currentAnimation = name;
        currentFrame = 0;
        isAnimating = true;
    }

    public function stopAnimation() {
        isAnimating = false;
    }

    public function updateAnimation() {
        if (!isAnimating || currentAnimation == "" || !animations.exists(currentAnimation)) return;

        var frames:Array<Int> = animations.get(currentAnimation);
        currentFrame++;

        if (currentFrame >= frames.length) {
            if (isAnimating) currentFrame = 0;
            else currentFrame = frames.length - 1;
        }
    }

    public function render(?targetX:Int = null, ?targetY:Int = null, ?targetWidth:Int = null, ?targetHeight:Int = null) {
        if (texture == null) return;

        if (isAnimating && currentAnimation != "" && animations.exists(currentAnimation)) {
            var frames:Array<Int> = animations.get(currentAnimation);
            if (frames.length > 0 && currentFrame < frames.length) {
                var frame:Int = frames[currentFrame];
                var srcRect:Rectangle = Rectangle.create(frameWidth * frame, 0, frameWidth, frameHeight);
                var dstRect:Rectangle = Rectangle.create(
                    targetX != null ? targetX : position.x,
                    targetY != null ? targetY : position.y,
                    targetWidth != null ? targetWidth : Std.int(frameWidth * scale.x),
                    targetHeight != null ? targetHeight : Std.int(frameHeight * scale.y)
                );

                SDL.renderCopy(Flexo.renderer, texture, srcRect, dstRect);
            }
        } else {
            var srcRect:Rectangle = Rectangle.create(0, 0, textureSize.x, textureSize.y);
            var dstRect:Rectangle = Rectangle.create(
                targetX != null ? targetX : position.x,
                targetY != null ? targetY : position.y,
                targetWidth != null ? targetWidth : Std.int(textureSize.x * scale.x),
                targetHeight != null ? targetHeight : Std.int(textureSize.y * scale.y)
            );

            SDL.renderCopy(Flexo.renderer, texture, srcRect, dstRect);
        }
    }

    public function setPosition(x:Int, y:Int):Void {
        position.x = x;
        position.y = y;
    }

    public function setScale(scaleX:Float, scaleY:Float):Void {
        scale.x = scaleX;
        scale.y = scaleY;
    }

    public static function cleanup() {
        Image.quit();
    }
}
