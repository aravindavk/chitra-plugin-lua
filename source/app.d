import std.stdio;
import std.getopt;
import std.file : readText;

import chitra_lua;

int main(string[] args)
{
    string inputFile;
    string code;
    auto helpInformation = getopt(
        args,
        "f|file",  "Input file", &inputFile,
        "c|code", "Input Code", &code
    );

    if (helpInformation.helpWanted)
    {
        defaultGetoptPrinter("Chitra CLI", helpInformation.options);
        return 0;
    }

    if (code == "")
        code = readText(inputFile);

    fromLuaString(code);
    return 0;
}
