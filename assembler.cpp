#include <iostream>
#include <fstream>
#include <map>
#include <vector>
#include <bits/stdc++.h>
using namespace std;

string DecimalToBinary(int num)
{
    string str;
    int b = 0;
    while(b < 8){
      if(num & 1) // 1
        str+='1';
      else // 0
        str+='0';
      num>>=1; // Right Shift by 1  
      b++;
    }   
    reverse(str.begin(),str.end()); 
    return str;
}

int main(){
    ifstream sourcecode("code.asm");
    ifstream dictinst("dict.txt");
    ofstream assembly("bytecode.bin", ios::binary | ios::out);
    map<string,pair<string,pair<int,int>>> instructions;
    vector<string> code;
    string line;
    string instruction;

    while(dictinst >> instruction){
            string opcode;
            int type,parameters;
            dictinst >> type >> parameters >> opcode;
            pair<int,int> p = make_pair(type,parameters);
            pair<string,pair<int,int>> f = make_pair(opcode,p);
            instructions[instruction] = f;
    }

    while(sourcecode >> line){
        if(line[0] != '/'){
            code.push_back(line);
        }        
    }
    for(int i = 0; i < code.size(); i++){
        line = code[i];
        if(isalpha(line[0])){
            if(instructions.find(line) != instructions.end()){
                if(instructions[line].second.first == 1){
                if(instructions[line].second.second == 1){
                    assembly.write("00000001\n",9);
                }else if (instructions[line].second.second == 2){
                    assembly.write("00000010\n",9);
                }
                for(int j = 1; j <= instructions[line].second.second ; j++){
                    if(isalpha(code[i+j][0])){
                        cout << "Missing a parameter " << i << endl;
                    }
                }
                }
                assembly.write((instructions[line].first.c_str()),instructions[line].first.length());
                assembly.write("\n",1);
            }else{
                cout << "Unknow input at line " << i << endl;
                return 0; 
            }
        }else{
            string aux = DecimalToBinary(stoi(line));
            assembly.write((aux.c_str()),aux.length());
            assembly.write("\n",1);
        }
    }
    

    assembly.write("11111111",8);
    sourcecode.close();
    dictinst.close();
    assembly.close();
}