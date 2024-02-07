package flexo;

import sdl.SDL;
import sdl.Surface;
import sdl.Texture;
import sdl.Image;
import haxe.Timer;

class Sprite {
    public var texture:Texture;
    public var textureSize:Point;
    public var position:Point;
    public var scale:FPoint;
    public var frameWidth:Int;
    public var frameHeight:Int;
    private var animations:Map<String, Array<Int>>;
    private var currentAnimation:String;
    private var animationFrames:Array<Int>;
    private var animationIndex:Int;
    private var isAnimating:Bool;
    private var isLooping:Bool;

    public function new() {
        position = Point.create(0, 0);
        scale = FPoint.create(1, 1);
        animations = new Map<String, Array<Int>>();
        currentAnimation = "";
        animationIndex = 0;
        isAnimating = false;
        isLooping = false;
    }

    public function loadImage(path:String, frameWidth:Int = 0, frameHeight:Int = 0):Void {
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

    public function render(?targetX:Int = null, ?targetY:Int = null, ?targetWidth:Int = null, ?targetHeight:Int = null) {
        if (isAnimating) {
            var currentFrame = animationFrames[animationIndex];
            var sourceRect = Rectangle.create(currentFrame * frameWidth, 0, frameWidth, frameHeight);
            var destRect = Rectangle.create(
                targetX != null ? targetX : position.x,
                targetY != null ? targetY : position.y,
                targetWidth != null ? targetWidth : Std.int(frameWidth * scale.x),
                targetHeight != null ? targetHeight : Std.int(frameHeight * scale.y)
            );
            SDL.renderCopy(Flexo.renderer, texture, sourceRect, destRect);
        } else {
            var sourceRect = Rectangle.create(0, 0, textureSize.x, textureSize.y);
            var destRect = Rectangle.create(
                targetX != null ? targetX : position.x,
                targetY != null ? targetY : position.y,
                targetWidth != null ? targetWidth : Std.int(textureSize.x * scale.x),
                targetHeight != null ? targetHeight : Std.int(textureSize.y * scale.y)
            );
            SDL.renderCopy(Flexo.renderer, texture, sourceRect, destRect);
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

    public function addAnimation(name:String, frames:Array<Int>):Void {
        animations.set(name, frames);
    }

    public function playAnimation(name:String, loop:Bool = false):Void {
        if (!animations.exists(name)) {
            Sys.println("Animation " + name + " not found.");
            return;
        }

        currentAnimation = name;
        animationFrames = animations.get(name);
        animationIndex = 0;
        isAnimating = true;
        isLooping = loop;

        if (isAnimating) {
            Timer.delay(playNextFrame, Std.int(1000 / 12));
        }
    }

    private function playNextFrame():Void {
        if (isAnimating) {
            animationIndex++;
            if (animationIndex >= animationFrames.length) {
                if (isLooping) {
                    animationIndex = 0;
                } else {
                    isAnimating = false;
                    return;
                }
            }
            Timer.delay(playNextFrame, Std.int(1000 / 12));
        }
    }

    public static function cleanup() {
        Image.quit();
    }
}
