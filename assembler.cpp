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
        // Se a linha possuir uma barra no início (indicativo de comentário)
        if (line[0] != '/')
        {
            code.push_back(line); // Adiciona a linha ao vetor do código reescrito em binário
            comments.push_back(comments[n-1]); // #
        } else { // #
            comments.push_back(comments[n-1]+1); // #
        }
        n++; // Atualiza o contador
    }

    // * Loop que percorre todo o código
    for (int i = 0; i < code.size(); i++)
    {
        line = code[i]; // Linha atual

        // Veja se é uma instrução (identificado pelo primeiro caractere caso seja uma letra)
        if (isalpha(line[0])) 
        {
            // Caso sim, veja se ela existe no dicionário
            if (instructions.find(line) != instructions.end())
            {
                // * Checagem do tipo de função por meio do acesso aos pares
                // Se for 1, adicione antes do opcode o número de parâmetros (Somente as funções que vão pra ALU)
                if (instructions[line].second.first == 1)
                {
                    // Verifica se a função precisa de 1 parâmetro
                    if (instructions[line].second.second == 1)
                    {
                        // Escreve o equivalente no arquivo de saída
                        assembly.write("00000001\n", 9);
                    }
                    // Verifica se a função precisa de 2 parâmetros
                    else if (instructions[line].second.second == 2)
                    {
                        // Escreve o equivalente no arquivo de saída
                        assembly.write("00000010\n", 9);
                    }
                }

                // * Tratamento da instrução JUMPZ
                // Se a linha lida for relativa a instrução do opcode JUMPZ (altera o fluxo do código com base em uma comparação)
                if (line == "JUMPZ"){
                    int k = i + 3; // Define um contador que indica a próxima função ao JUMPZ
                    assembly.write("00000010\n", 9); // Escreve na saída a indicação do tipo e parâmetro da função que vai ser relida
                    // Se a próxima linha do código não for um operador comparativo
                    if (code[i + 1] != "GREATER" && code[i + 1] != "EQUAL" && code[i + 1] != "LESS"){
                        // Será inválido, pois a função precisa de um operador de comparação para saber se vai pular#
                        // Imprime a mensagem de erro e indica a linha
                        cout << "Invalid syntax line " << i + 1 << "JUMPZ require a compare operator\n"; 
                    }
                    // Escreva na saída: a instrução referente ao código JUMPZ em um vetor de caracteres e o seu tamanho#
                    assembly.write((instructions[code[i + 1]].first.c_str()), instructions[code[i + 1]].first.length());
                    // #
                    assembly.write("\n", 1);

                    // #
                    for (i = i + 2; i <= k; i++){
                        if (isalpha(code[i][0])){
                            cout << "Missing a parameter " << i << " " << code[i] << endl;
                        }
                        string aux = DecimalToBinary(stoi(code[i]));
                        assembly.write((aux.c_str()), aux.length());
                        assembly.write("\n", 1);
                    }

                // * Checagem do número de parâmetros e tratamento das outras funções
                } else {
                    // Se a o número de parâmetros da função lida for maior que zero
                    if (instructions[line].second.second > 0){
                    // Faça um laço que percorre de 1 até a quantidade indicada de parâmetros
                    for (int j = 1; j <= instructions[line].second.second; j++)
                    {
                        // Verifica se o parâmetro começa com uma letra, caso sim, significa que a quantidade de
                        // parâmetros não foi atingida e um novo comando foi iniciado prematuramente
                        if (isalpha(code[i + j][0]))
                        {
                            // Imprime a mensagem de erro
                            cout << "Missing a parameter " << i << " " << line << endl;
                        }
                    }
                    }
                }
                // Escreve na saída a função correspondente em um vetor de caracteres e o tamanho desse vetor
                assembly.write((instructions[line].first.c_str()), instructions[line].first.length());
                // O que significa esse "1"#
                assembly.write("\n", 1);

                // * Lógica do JUMPZ
                // Caso a linha analisada seja uma instrução de desvio condicional
                if (line == "JUMPZ"){
                    // Verifique se o primeiro caractere da linha lida é uma letra
                    if (isalpha(code[i][0])){
                        // Caso seja, outro código foi começado prematuramente e falta parâmetros
                        // Imprima a mensagem indicativa
                        cout << "Missing a parameter " << i << " " << code[i] << endl;
                    }

                    // Transforma um número de decimal para binário
                    // Nesse caso é feito o cálculo do endereço de desvio, onde o resultado é:
                    // #
                    string aux = DecimalToBinary(stoi(code[i]) - comments[stoi(code[i])] - 1);
                    // Escreve na saída os números em formato de vetor de char e o tamanho do vetor#
                    assembly.write((aux.c_str()), aux.length());
                    // #
                    assembly.write("\n", 1);
                
                // * Lógica do JUMP
                } else if (line == "JUMP"){
                    // Pula uma linha
                    i++;
                    // #
                    string aux = DecimalToBinary(stoi(code[i]) - comments[stoi(code[i])] - 1);
                    // #
                    assembly.write((aux.c_str()), aux.length());
                    // #
                    assembly.write("\n", 1);
                }
            }

            // * Tratamento de função inexistente
            // Caso não exista no dicionário
            else
            {
                // Imprima a mensagem de erro
                cout << "Unknow input at line " << i << " " << line << endl;
                return 0;
            }
        }

        // * Transformação dos números decimais do código-fonte em binário para a leitura do processador
        // Caso não seja uma instrução (é um número)
        else
        {
            string aux = DecimalToBinary(stoi(line)); // String que recebe o representativo binário do número decimal escrito
            // A função stoi faz a transformação de um número decimal tipo string para seu tipo int
            // Escreve na saída os números em formato de vetor de char e o tamanho do vetor#
            assembly.write((aux.c_str()), aux.length());
            // #
            assembly.write("\n", 1);
        }
    }


    // Finaliza o código transcrito
    assembly.write("11111111", 8);

    // Fecha os arquivos
    sourcecode.close();
    dictinst.close();
    assembly.close();
}