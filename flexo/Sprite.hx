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
    public var frameWidth:Int;
    public var frameHeight:Int;
    public var isSpriteSheet:Bool;
    public var curAnim:String;
    public var curFrame:Int;
    public var frames:Map<String, Array<Int>>;
    public var animations:Map<String, Animation>;
    public var paused:Bool;
    public var finished:Bool;
    public var callback:Void->Void;

    public function new() {
        position = Point.create(0, 0);
        scale = FPoint.create(1, 1);

        curAnim = "";
        curFrame = 0;
        frames = new Map<String, Array<Int>>();
        animations = new Map<String, Animation>();
        paused = true;
        finished = true;
        callback = null;
    }

    public function loadImage(path:String, frameWidth:Int = 0, frameHeight:Int = 0, isSpriteSheet:Bool = false):Void {
        this.isSpriteSheet = isSpriteSheet;
        if (isSpriteSheet) {
            loadSpriteSheet(path, frameWidth, frameHeight);
        } else {
            loadSingleImage(path);
        }
    }

    private function loadSingleImage(path:String):Void {
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

        this.frameWidth = textureSize.x;
        this.frameHeight = textureSize.y;
    }

    private function loadSpriteSheet(path:String, frameWidth:Int, frameHeight:Int):Void {
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

        this.frameWidth = frameWidth;
        this.frameHeight = frameHeight;

        var framesPerRow:Int = Std.int(textureSize.x / frameWidth);
        var framesPerColumn:Int = Std.int(textureSize.y / frameHeight);
        var frameIndexes:Array<Int> = [];
        for (i in 0...framesPerRow) {
            for (j in 0...framesPerColumn) {
                var frameIndex:Int = j * framesPerRow + i;
                frameIndexes.push(frameIndex);
            }
        }
        frames.set("default", frameIndexes);
        animations.set("default", new Animation("default", 1.0, true, frameIndexes.length));
    }

    public function render(?targetX:Int = null, ?targetY:Int = null, ?targetWidth:Int = null, ?targetHeight:Int = null) {
        var srcRect:Rectangle;

        if (isSpriteSheet) {
            var frameIndex:Int = frames.get(curAnim)[curFrame];
            var frameColumn:Int = Std.int(frameIndex % (textureSize.x / frameWidth));
            var frameRow:Int = Std.int(frameIndex / (textureSize.y / frameWidth));
            srcRect = Rectangle.create(frameWidth * frameColumn, frameHeight * frameRow, frameWidth, frameHeight);
        } else {
            srcRect = Rectangle.create(0, 0, textureSize.x, textureSize.y);
        }

        SDL.renderCopy(Flexo.renderer, texture,
            srcRect,
            Rectangle.create(
                targetX != null ? targetX : position.x,
                targetY != null ? targetY : position.y,
                targetWidth != null ? targetWidth : Std.int(frameWidth * scale.x),
                targetHeight != null ? targetHeight : Std.int(frameHeight * scale.y)
            )
        );
    }

    public function addAnimation(animName:String, frameIndexes:Array<Int>, frameRate:Float = 12, looped:Bool = true):Sprite {
        frames.set(animName, frameIndexes);
        animations.set(animName, new Animation(animName, frameRate, looped, frameIndexes.length));
        return this;
    }

    public function playAnimation(animName:String, force:Bool = false):Sprite {
        if (!force && curAnim == animName) return this;
        curAnim = animName;
        curFrame = 0;
        paused = false;
        finished = false;
        return this;
    }

    public function pauseAnimation():Sprite {
        paused = true;
        return this;
    }

    public function resumeAnimation():Sprite {
        paused = false;
        return this;
    }

    public function restartAnimation():Sprite {
        curFrame = 0;
        finished = false;
        return this;
    }

    public function stopAnimation():Sprite {
        paused = true;
        finished = true;
        return this;
    }

    public function update():Void {
        if (paused || finished) return;

        var animation:Animation = animations.get(curAnim);
        if (animation == null) return;

        animation.update(Flexo.elapsed);

        curFrame = animation.curIndex;
        if (curFrame >= animation.frames.length) {
            finished = true;
            if (callback != null) callback();
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

    public function setCallback(callback:Void->Void):Sprite {
        this.callback = callback;
        return this;
    }

    public function isFinished():Bool {
        return finished;
    }

    public static function cleanup() {
        Image.quit();
    }
}

class Animation {
    public var name:String;
    public var frameRate:Float;
    public var looped:Bool;
    public var frames:Array<Int>;
    public var curIndex:Int;
    public var timer:Float;
    public var elapsed:Float;

    public function new(name:String, frameRate:Float, looped:Bool, frameCount:Int) {
        this.name = name;
        this.frameRate = frameRate;
        this.looped = looped;
        frames = new Array<Int>();
        for (i in 0...frameCount) frames.push(i);
        curIndex = 0;
        timer = 0;
        elapsed = 0;
    }

    public function update(elapsed:Float):Void {
        this.elapsed += elapsed;
        var frameDuration:Float = 1.0 / frameRate;

        while (this.elapsed >= frameDuration) {
            curIndex++;
            if (curIndex >= frames.length) {
                if (looped) {
                    curIndex = 0;
                } else {
                    curIndex = frames.length - 1;
                    break;
                }
            }
            this.elapsed -= frameDuration;
        }
    }
}
