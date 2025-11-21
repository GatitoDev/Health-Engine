package data;

import flixel.text.FlxText;
import flixel.util.FlxColor;

class Text extends FlxText
{
    public function new(X:Float = 0, Y:Float = 0, FieldWidth:Int = 0, ?Text:String, Size:Int = 16, 
     Color:FlxColor = FlxColor.WHITE, Font:String = "vcr", ?Alignment:FlxTextAlign = CENTER, 
     ?BorderStyle:FlxTextBorderStyle, BorderColor:FlxColor = FlxColor.BLACK, BorderSize:Float = 1)
    {
        super(X, Y, FieldWidth, Text, Size);
        setFormat(Font, Size, Color, Alignment, BorderStyle, BorderColor);
        setBorderStyle(BorderStyle ?? NONE, BorderColor, BorderSize);
        this.scrollFactor.set();
    }
    public function center(Width:Float = -1):Text {Width <= 0 ? screenCenter(X) : x = (Width - width) / 2; return this;}
}