import flixel.util.FlxStringUtil;
import flixel.FlxG;

class Ratings {
    public static function GenerateLetterRank(accuracy:Float):String {
        if (FlxG.save.data.botplay) return "BotPlay";
        if (accuracy == 0) return "N/A";

        var ranking:String = switch ([PlayState.misses, PlayState.bads, PlayState.shits, PlayState.goods]) {
            case [0, 0, 0, 0]: "(MFC)";
            case [0, 0, 0, _]: "(GFC)";
            case [0, _, _, _]: "(FC)";
            case [m, _, _, _] if (m < 10): "(SDCB)";
            default: "(Clear)";
        };

        final thresholds:Array<{rank:String, min:Float}> = [
            {min: 99.9935, rank: " AAAAA"},
            {min: 99.980,  rank: " AAAA:"},
            {min: 99.970,  rank: " AAAA."},
            {min: 99.955,  rank: " AAAA"},
            {min: 99.90,   rank: " AAA:"},
            {min: 99.80,   rank: " AAA."},
            {min: 99.70,   rank: " AAA"},
            {min: 99,      rank: " AA:"},
            {min: 96.50,   rank: " AA."},
            {min: 93,      rank: " AA"},
            {min: 90,      rank: " A:"},
            {min: 85,      rank: " A."},
            {min: 80,      rank: " A"},
            {min: 70,      rank: " B"},
            {min: 60,      rank: " C"}
        ];

        for (t in thresholds) {
            if (accuracy >= t.min) {
                ranking += t.rank;
                break;
            }
        }
        
        if (accuracy < 60) ranking += " D";
        return ranking;
    }
    
    public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String {
        if (FlxG.save.data.botplay) return "good";
        
        final timeScale:Float = (customSafeZone != null) ? customSafeZone / 166 : Conductor.timeScale;
        final absDiff:Float = Math.abs(noteDiff);
        
        return if (absDiff > 166 * timeScale) "miss"
            else if (absDiff > 135 * timeScale) "shit"
            else if (absDiff > 90 * timeScale) "bad"
            else if (absDiff > 45 * timeScale) "good"
            else "sick";
    }

    public static function CalculateRanking(score:Int, scoreDef:Int, accuracy:Float):String {
        var parts = [];
        final scoreFormatted:String = FlxStringUtil.formatMoney(score, false, true);
        
        if (!FlxG.save.data.botplay) {
            parts.push('Acc: ${HelperFunctions.truncateFloat(accuracy, 2)}%');
            parts.push(GenerateLetterRank(accuracy));
            parts.push('Miss: ${PlayState.misses}');
            parts.push('Score: ${Conductor.safeFrames != 10 ? '$scoreFormatted ($scoreDef)' : scoreFormatted}');
        }
        
        return parts.join("  ");
    }
}