import std.algorithm;
import std.conv;
import std.format;
import std.meta;
import std.range;

auto shift(Range)(ref Range r)
{
    auto e = r.front;
    r.popFront();
    return e;
}

struct SentenceID
{
    long docID;
    int sentNum;
    int paragraph;

    this(char[] s)
    {
        auto parts = s.splitter('.');
        foreach (ref e; AliasSeq!(docID, sentNum, paragraph))
        {
            e = parts.shift.to!(typeof(e));
        }
    }

    mixin(AutoConstructor!(docID, sentNum, paragraph));

    string toString()
    {
        return format("%d.%d.%d", docID, sentNum, paragraph);
    }
}

struct SynonymeID
{
    int fileID, lineID, synID;

    this(char[] s)
    {
        auto parts = s.splitter(':').map!(to!int);
        foreach (ref e; AliasSeq!(fileID, lineID, synID))
        {
            e = parts.shift;
        }
    }

    mixin(AutoConstructor!(fileID, lineID, synID));

    string toString()
    {
        return format("%d:%d:%d", fileID, lineID, synID);
    }
}

struct SyngrepIndexHit
{
    SentenceID pmidID;
    SynonymeID synID;
    string matchedSyn;
    int foundSynStart, foundSynLength;
    string foundSyn;
    bool caseMatch;

    this(char[] s)
    {
        auto p = s.splitter('\t');
        pmidID = SentenceID(p.shift);
        synID = SynonymeID(p.shift);
        matchedSyn = p.shift.idup;
        foundSynStart = p.shift.to!int;
        foundSynLength = p.shift.to!int;
        foundSyn = p.shift.idup;
        caseMatch = p.shift == "true";
    }

    mixin(AutoConstructor!(pmidID, synID, matchedSyn, foundSynStart, foundSynLength, foundSyn, caseMatch));

    string toString()
    {
        return format("%s\t%s\t%s\t%s\t%s\t%s\t%s", pmidID, synID, matchedSyn, foundSynStart, foundSynLength, foundSyn, caseMatch ? "true" : "false");
    }
}

static string AutoConstructor(fields ...)()
{
    import std.meta: staticMap;
    import std.traits: fullyQualifiedName;
    import std.string: join;

    enum fqns = staticMap!(fullyQualifiedName, fields);
    auto fields_str = "std.meta.AliasSeq!(" ~ [fqns].join(", ") ~ ")";

    return "
        static import std.meta;
        this(typeof(" ~ fields_str ~ ") args)
        {
            " ~ fields_str ~ " = args;
        }
    ";
}
