#!/usr/bin/env rdmd

import data;
import std.algorithm;
import std.conv;
import std.file;
import std.getopt;
import std.range;
import std.path;
import std.stdio;
import std.uni;

struct SynEntry
{
    SynonymeID synID;
    string word;
}

auto parseSynFile(string file, int fileID)
{
    return File(file)
        .byLine
        .enumerate
        .map!((t){
            auto ps = t.value.splitter(':');
            return chain(ps.front.only, ps.dropOne.front.find!(e => !e.isWhite).splitter('|'))
                .enumerate
                .map!(e => SynEntry(SynonymeID(fileID, cast(int) t.index, cast(int) e.index), e.value.idup));
        })
        .joiner();
}

SynEntry[] entries;

void buildSynDatabase(string synDir)
{
    foreach (i, file; synDir.dirEntries(SpanMode.depth).filter!(f => f.name.endsWith(".syn")).enumerate)
    {
        writefln("parsing: %s", file.name);
        entries ~= parseSynFile(file.name, cast(int) i)
            //.take(10)
            .array;
        //break;
    }
    writefln("Synonyms: %d", entries.length);
}

auto sentences(R)(R range)
{
    auto sentences = range.splitter(".");
    return sentences.filter!(e => e.length > 1);
}

auto parsePubmed(string file)
{
    long docID = file.baseName.stripExtension.to!long;
    foreach (i, sentence; file.readText.sentences.enumerate)
    {
        auto sentID = SentenceID(docID, cast(int) i, 0);
        foreach (const ref entry; entries)
        {
            if (!sentence.find(entry.word).empty)
            {
                auto hit = SyngrepIndexHit(sentID, entry.synID, entry.word, 0, 0, entry.word, true);
                hit.writeln;
            }
        }
    }
}

void main(string[] args)
{
    auto synDir = ".";
    auto info = getopt(args,
        "syndir", &synDir
    );
    if (info.helpWanted)
    {
        import core.stdc.stdlib : exit;
        defaultGetoptPrinter("SynGrep", info.options);
        exit(0);
    }
    synDir.buildSynDatabase;

    if (args.length > 1)
    {
        args[1].parsePubmed;
    }
}
