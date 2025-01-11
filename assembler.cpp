#include <iostream>
#include <fstream>
#include <map>

using namespace std;

int main(){
    ifstream sourcecode("code.asm");
    ifstream dictinst("dict.txt");
    ofstream assembly("bytecode.bin", ios::binary | ios::out);
    map<string,string> instructions;
    string line;
    string instruction;

    while(dictinst >> instruction){
        string opcode;
        dictinst >> opcode;
        instructions[instruction] = opcode;
    }

    int x = 0;
    while(sourcecode >> line){
        if(isalpha(line[0])){
            assembly.write((instructions[line].c_str()),instructions[line].length());
        }else{
            assembly.write((line.c_str()),line.length());
        }

        x++;
    }
    sourcecode.close();
    dictinst.close();
    assembly.close();
}