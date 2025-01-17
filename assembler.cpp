// Inclusão de bibliotecas e adição de funcionalidades
#include <iostream>
#include <fstream>
#include <map>
#include <vector>
#include <bits/stdc++.h>
using namespace std;

// * Função de transformação de decimal (base 10) para binário (base 2)
// Entrada: int num (número decimal inteiro a ser transformado)
// Saída: str (string que representa a conversão binária)
string DecimalToBinary(int num)
{
    string str; // Armazena o número binário como texto
    int b = 0; // Contador para controlar até 8 bits
    // Loop de cálculo para cada bit
    while (b < 8)
    {
        /* Processo de reescrita do número e atribuição à string:
        O operador & já interpreta o número decimal como sua representação binária
        e após a checagem adiciona o respectivo número (em formato de char) à string */
        if (num & 1)
            str += '1';
        else
            str += '0';
        num >>= 1; // Diminui o bit menos significativo do número (mais à direita)
        b++; // Atualiza o contador
    }
    // Inverte a string, pois a leitura é feita de forma inversa (do menos ao mais significativo)
    reverse(str.begin(), str.end());
    // Retorna a string já convertida
    return str;
}

int main()
{
    // * Abertura dos arquivos para leitura
    ifstream sourcecode("code.asm"); // Código-fonte escrito pelo usuário
    ifstream dictinst("dict.txt"); // Dicionário com: as funções (palavras), seu tipo (alu ou não alu),
    // quantidade de parâmetros e a equivalência em binário
    // Criação de um arquivo de saída em binário (será interpretado pelo processador)
    ofstream assembly("bytecode.bin", ios::binary | ios::out);

    // * Definição da estrutura de variáveis que serão usadas
    // Map: função que associa chaves a valores
    // Chave: String da função. Ex: MOV
    // Valor: Par composto pelo opcode (operation code) e outro par de inteiros com o tipo de função
    // e a quantidade de parâmetros. Ex: <MOV, (1, 2)>
    // O resultado é armazenado na variável instructions
    map<string, pair<string, pair<int, int>>> instructions;
    vector<int> comments; // Vetor de inteiros que representam as linhas dos comentários
    vector<string> code; // Vetor de strings que representam o código reescrito em binário
    string line; // String que recebe a linha atual no loop de leitura
    string instruction; // String que recebe a instrução atual no loop de leitura

    // * Criação do dicionário de funções que será interpretado pelo compilador
    // Loop que percorre linha a linha o dicionário de instruções e armazena na variável instruction 
    while (dictinst >> instruction)
    {
        string opcode; // Variável do opcode da função lida
        int type, parameters; // Variável do tipo e parâmetro da função lida
        dictinst >> type >> parameters >> opcode; // Lê mais três linhas e atribui às variáveis
        // Par de opcode + tipo + quantidade de parâmetros
        pair<int, int> p = make_pair(type, parameters);
        pair<string, pair<int, int>> f = make_pair(opcode, p);
        // Salva a instrução lida no dicionário
        instructions[instruction] = f;
    }
    
    // * Identificação de comentários no código-fonte
    comments.push_back(0); // Inicia o vetor de comentários com 0
    int n = 1; // Contador que acompanha a linha do código lida
    while (sourcecode >> line) // Lê cada linha do código-fonte
    {
        // Se a linha possuir uma barra (indicativo de comentário)
        if (line[0] != '/')
        {
            code.push_back(line); // Adiciona a linha ao vetor do código reescrito em binário
            comments.push_back(comments[n-1]); // Adiciona ao vetor de comentários o comentário atual
        } else{ // Caso não
            comments.push_back(comments[n-1]+1);
        }
        n++; // Atualiza o contador
    }

    for (int i = 0; i < code.size(); i++)
    {
        line = code[i];
        if (isalpha(line[0]))
        {
            if (instructions.find(line) != instructions.end())
            {
                if (instructions[line].second.first == 1)
                {
                    if (instructions[line].second.second == 1)
                    {
                        assembly.write("00000001\n", 9);
                    }
                    else if (instructions[line].second.second == 2)
                    {
                        assembly.write("00000010\n", 9);
                    }
                }
                if(line == "JUMPZ"){
                    int k = i+ 3;
                    assembly.write("00000010\n", 9);
                    if(code[i+1] != "GREATER" && code[i+1] != "EQUAL" && code[i+1] != "LESS"){
                        cout << "invalid syntax line " << i+1 << " JUMPZ require a compare operator\n"; 
                    }
                    assembly.write((instructions[code[i+1]].first.c_str()), instructions[code[i+1]].first.length());
                    assembly.write("\n", 1);
                    for(i = i+2; i <= k;i++){
                        if(isalpha(code[i][0])){
                            cout << "Missing a parameter " << i << " " << code[i] << endl;
                        }
                        string aux = DecimalToBinary(stoi(code[i]));
                        assembly.write((aux.c_str()), aux.length());
                        assembly.write("\n", 1);
                    }
                }else{
                    if(instructions[line].second.second > 0){
                    for (int j = 1; j <= instructions[line].second.second; j++)
                    {
                        if (isalpha(code[i + j][0]))
                        {
                            cout << "Missing a parameter " << i << " " << line << endl;
                        }
                    }
                    }
                }
                assembly.write((instructions[line].first.c_str()), instructions[line].first.length());
                assembly.write("\n", 1);
                if(line == "JUMPZ"){
                    if(isalpha(code[i][0])){
                        cout << "Missing a parameter " << i << " " << code[i] << endl;
                    }
                    string aux = DecimalToBinary(stoi(code[i])-comments[stoi(code[i])]-1);
                    assembly.write((aux.c_str()), aux.length());
                    assembly.write("\n", 1);
                }else if(line=="JUMP"){
                    i++;
                    string aux = DecimalToBinary(stoi(code[i])-comments[stoi(code[i])]-1);
                    assembly.write((aux.c_str()), aux.length());
                    assembly.write("\n", 1);
                }
            }
            else
            {
                cout << "Unknow input at line " << i << " " << line << endl;
                return 0;
            }
        }
        else
        {
            string aux = DecimalToBinary(stoi(line));
            assembly.write((aux.c_str()), aux.length());
            assembly.write("\n", 1);
        }
    }
    assembly.write("11111111", 8);
    sourcecode.close();
    dictinst.close();
    assembly.close();
}