%{
#include <iostream> 
#include <vector>
#include <stack> 
#include <map>
#include <stdio.h>
#include "Symbol.h"
#include "Util.h"

/* Alfabetul */ 
std::vector<char> alphabet;
/* Masinile Turing din fisierul sursa */
std::map<std::string, TuringCell*> turing_machines; 
TuringCell *pmachine, *machine, *last_cell;
std::string last_name = "", machine_name = "", 
			variable_name = "", array_name = "", local_variable_name ="";
/* Stiva de stari se trebuie salvate in cazul in care 
 * exista o ramificatie. Toate ramificatiile trebuie 
 * adaugate la ultima stare din stiva. Avem nevoie de
 * o stiva pentru ca poate exista o ramificatie in 
 * interiorul altei ramificatii */
std::stack<TuringCell*> saved_states;
/* Cheile asociate unei ramificatii. Toate cheile pastrate in vector la un 
   moment dat se gasesc in interiorul aceeasi perechi de acolade. */
std::vector<Symbol*> keys;
/* Un map care pastreaza variabilele. */ 
std::map<std::string, char> variables;
/* Un map care pastreaza vectorii de caractere */
std::map<std::string, std::vector<char> > arrays;
/* Un map care pastreaza variabilele locale */
std::map<char, Symbol*> local_variables;
int curly_braces = 0, simple_braces = 0, angled_braces = 0;
// Se poate nega cheia din interiorul unei ramificatii
bool key_negated = false;

%}

DIGIT		[0-9]
LETTER		([a-z]|[A-Z])
OTHER		[#$*@]

SYMBOL		{DIGIT}|{LETTER}|{OTHER}
NAME		({LETTER}|{DIGIT}|_)+({LETTER}|{DIGIT}|_)+

%option yylineno

%x ALPHABET TURING TURING_NAME TURING_ACTION TURING_CHAR 
%x TURING_RAMIF TURING_LINK VARIABLE ARRAY LOCAL_VARIABLE VARIABLE_LINK
%x LOCAL_VARINV

%%
 /* Stari initiale de baza care conduc la alte stari particulare */
 /* Incepe declararea alfabetului */
<INITIAL>(alphabet)[ ]*::  	{ BEGIN(ALPHABET); }
 /* Comentariu pe o singura linie */
<INITIAL>^;.*		{ 
	//std::cout << "Skipped this comment" << yytext << std::endl; 
}
 /* Incepe declararea unei variabile */
<INITIAL>{NAME}/[ ]*= 		{
	variable_name = std::string(yytext);
	BEGIN(VARIABLE);
}
 /* Incepe declararea unui vector de simboluri */
<INITIAL>{NAME}/[ ]*:=		{
	array_name	= std::string(yytext); 
	BEGIN(ARRAY);
}
 /* Incepe declararea unei masini Turing */
<INITIAL>{NAME}/[ ]*::=		{ 
	machine_name = std::string(yytext);
	last_cell = new TuringCell;
	machine = last_cell;
	pmachine = machine;
	simple_braces = 0;
	BEGIN(TURING); 
}
<INITIAL>[.\n\t ]	{}
<INITIAL><<EOF>>	{ 
	//std::cout << "Size:" << turing_machines.size() << std::endl;
	//pmachine->printTuringMachine();
	return 0;  
}

 /* Stare caracteristica declararii alfabetului */ 
<ALPHABET>{SYMBOL}	{
	if (strlen(yytext)>1){
		std::cout << "Simbolurile din alfabet trebuie sa contina 1 caracter ";
		std::cout << "@line: " << yylineno << std::endl;
		return 1;
	}
	else {
		 alphabet.push_back(yytext[0]);
	}
}
<ALPHABET>[\n\t ] 	{}
<ALPHABET>;		 	{ BEGIN(INITIAL); }

 /* Stare caracteristica declararii unei variabile */
<VARIABLE>[=\n\t ]	{}
<VARIABLE>{SYMBOL}	{ variables[variable_name] = yytext[0]; }
<VARIABLE>;			{ BEGIN(INITIAL); }

 /* Stare caracteristica declararii unui vector de simboluri */
<ARRAY>:=|[\n\t, ]	{}
<ARRAY>"{"			{ curly_braces++; }
<ARRAY>"}"			{ curly_braces--; }
<ARRAY>;			{ 
	if (curly_braces!=0){
		std::cout << "Acoladele nu sunt balansate @line " << yylineno << std::endl; 
		return 1;
	}
	BEGIN(INITIAL);
}
<ARRAY>{SYMBOL}		{ 
	if (arrays.find(array_name) == arrays.end()){	
		arrays[array_name] = std::vector<char>();
	}
	arrays[array_name].push_back(yytext[0]); 
}

 /* Stare caracteristica declararii unei variabile locale intr-o ramificatie */
<LOCAL_VARIABLE>@		{}
<LOCAL_VARIABLE>"!{"	{
	key_negated = true;
}
<LOCAL_VARIABLE>"<"		{ angled_braces++; }
<LOCAL_VARIABLE>{NAME} 	{
	/* Variabila este un vector. Asadar vom creea un simbol din
	   toate elementele vectorului. */
	if (arrays.find(yytext)==arrays.end() &&
		variables.find(yytext)==variables.end()){
		std::cout << "Vectorul/variabila " << yytext << " nu e definit @line ";
		std::cout << yylineno << std::endl;
		return 1; 
	}
	
	Symbol *key = new Symbol();
	
	if (!key_negated){
		for(unsigned int i=0; i<arrays[yytext].size(); i++){
			key->addChar(arrays[yytext][i]);
		}
	}
	else{
		// Se adauga toate caracterele din alfabet la simbol 
		// cu exceptia celor continute in variabila negata.
		// Variabila poate fi si un vector
		bool ok;
		for(unsigned int i=0; i<alphabet.size(); i++){
			ok = true;
			if (arrays.find(yytext)!=arrays.end()){
				for(unsigned int j=0; j<arrays[yytext].size(); j++){
					if (alphabet[i]==arrays[yytext][j]){
						ok = false;
					}
				}
			}
			else if (variables.find(yytext)!=variables.end()){
				if (alphabet[i]==variables[yytext]){
					ok = false;
				}
			}
			if (ok){
				key->addChar(alphabet[i]);
			}
		}
		key_negated = false;
	}
	
	keys.push_back(key);
	local_variables[local_variable_name[0]] = keys.back();
}
<LOCAL_VARIABLE>">}"|">"		{ 
	angled_braces--; 
	if (angled_braces==0){
		BEGIN(TURING_RAMIF);
	}
}
 
 /* Stari caracteristice declararii unei masini Turing */
 
 /* Se sare peste operatorul de atribuire */
<TURING>[ ]*::=[ ]*	{}
 /* Se face match pe numele unei celule din masina Turing */
<TURING>{NAME}/@	{ last_name = yytext; BEGIN(TURING_NAME);  }
 /* Starea TURING_NAME este folosita doar pentru a evita ciclarea la infinit */
 /* pentru ca operatorul '/' nu avanseaza consumarea intrarii. */
<TURING_NAME>@		{ 
	if (simple_braces!=0){
		BEGIN(TURING_RAMIF);
	}
	else {
		BEGIN(TURING);
	}
}

 /* Se intra intr-o actiune ce trebuie efectuata asupra benzii. De exemplu */
 /* banda trebuie mutata la stanga sau la dreapta si/sau trebuie scris un */
 /* un simbol pe banda */
<TURING>"["			{ 
	if (last_name.length()!=0){
		last_cell->setName(last_name);
		machine->setAsLink();
		last_name = "";
	}
	BEGIN(TURING_ACTION); 
}

<TURING>&			{ BEGIN(TURING_LINK); } 

 /* Se intalneste o actiune de mutare pe banda pana la intalnirea unui anumit */ 
 /* simbol ce va fi dat in continuare sau pana cand nu se mai citeste un */
 /* anumit simbol (ex: R[a] sau R[!a]). */ 
<TURING_ACTION>R|L  { 
	last_cell->setAction(yytext[0]);
}

 /* Se intalneste numele unei alte masini definite anterior */ 
<TURING_ACTION>{NAME} { 
	bool found = false; 
	std::map<std::string, TuringCell*>::iterator it;
	for(it=turing_machines.begin(); it!=turing_machines.end(); it++){
		if (it->first == yytext){
			found = true;
			break;
		}
	}
	if (!found){
		std::cout << "Masina Turing " << yytext << " nu exista "; 
		std::cout << "@line: " << yylineno << std::endl;
		return 1;
	}
	last_cell->setMachineName(yytext);
}

 /* Se intalneste o actiune de scriere directa pe banda la pozitia in care */ 
 /* suntem cu capul de citire/scriere */
<TURING_ACTION>{SYMBOL} { last_cell->setSymbol(yytext[0]); }
 /* Se invoca o variabila locala */
<TURING_ACTION>&	{ BEGIN(LOCAL_VARINV); }
<TURING_ACTION>"("	{ BEGIN(TURING_CHAR);  }
<TURING_ACTION>"<"	{ angled_braces++; BEGIN(TURING_CHAR); }
 /* Sau in interiorul unei actiuni se poate invoca o variabila locala */ 
<TURING_CHAR>"<"	{ angled_braces++; }
<TURING_CHAR>&		{ BEGIN(LOCAL_VARINV); }
 /* Caracterul este dat printr-o variabila definita anterior */
<TURING_CHAR>{NAME}	{
	if (angled_braces!=0){
		if (variables.find(yytext)==variables.end()){			
			std::cout << "Variabila " << yytext << " nu este declarata ";
			std::cout << "@line" << yylineno << std::endl;
			return 1;
		}
		else{ 
			last_cell->setSymbol(variables[yytext]);
		}
	}
}
<TURING_CHAR>(">"|">)")		{ 
	angled_braces--; 
	if (angled_braces==0){
		BEGIN(TURING_ACTION);
	}
}
 /* Caracterul pana la care se muta capul in directia data anterior */ 
<TURING_CHAR>{SYMBOL} { last_cell->setSymbol(yytext[0]); }

 /* Se poate intalni '!'. In acest caz mutarea area loc pana cand caracterul */
 /* de pe banda este diferit fata de cel setat in starea masinii */
<TURING_CHAR>!		{ last_cell->toggleNegated(); }
<TURING_CHAR>")"	{ BEGIN(TURING_ACTION); }
<TURING_ACTION>"]"	{
	/* In acest caz ne afla intr-o ramificatie. Si e chiar inceputul 
	 * ramificatiei cand avem o stare cu o cheie asociata. */ 
	if (simple_braces>0 && keys.size()!=0){
		
		machine = saved_states.top();
		std::vector<Symbol*>::iterator it; 
		for(it = keys.begin(); it!=keys.end(); it++){
			machine->addNext(*it, last_cell);	
		}
		machine = machine->getNext(*keys[0]);
		keys.clear();
	}
	last_cell = new TuringCell;
	if (machine->hasDefaultNext()){
		machine = machine->getDefaultNext();
		machine->setDefaultNext(last_cell);
	}
	else {
		machine->setDefaultNext(last_cell);
	}
	if (simple_braces>0){
		BEGIN(TURING_RAMIF);
	} 
	else { 
		BEGIN(TURING);
	}
}

 /* Starea ce defineste invocarea unei variabile locale */ 
<LOCAL_VARINV>{SYMBOL}")"|{SYMBOL}	{
	if (local_variables.find(yytext[0])==local_variables.end()){
		// Variabila locala invocata nu exista 
		std::cout << "Variabila locala " << yytext << " nu exista "; 
		std::cout << "@line " << yylineno << std::endl;
		return 1;
	}
	last_cell->setSymbol(local_variables[yytext[0]]);
	BEGIN(TURING_ACTION);
}

 /* Se intalneste o ramificatie. Asadar salvam starea curenta pentru ca */
 /* acesteia vom trebui sa ii adaugam mai multi vecini, care nu sunt cunoscuti*/ 
 /* la starea imediat urmatoare. */ 
<TURING>"("			{
	if (last_name.length()!=0){
		last_cell->setName(last_name);
		last_cell->setAction('N');
		machine->setAsLink();
	} 
	if (last_name.length()!=0){
		machine->setDefaultNext(last_cell);
		machine = machine->getDefaultNext();
		last_name = "";
	}
	saved_states.push(machine);
	last_cell = new TuringCell;
	curly_braces = 0;  
	simple_braces++;
	BEGIN(TURING_RAMIF); 
}

 /* In acest caz avem o ramificatie in interiorul unei ramificatii */ 
<TURING_RAMIF>"("			{ 
	saved_states.push(machine);
	last_cell = new TuringCell;
	curly_braces = 0;  
	simple_braces++;
	BEGIN(TURING_RAMIF); 
}
 /* Cheia va fi negata */
<TURING_RAMIF>!/"{"			{
	key_negated = true;
}
<TURING_RAMIF>"{"		{ last_cell = new TuringCell; curly_braces++; }
 /* Folosirea unei variable declarata global */
<TURING_RAMIF>"<"		{ angled_braces++; }
<TURING_RAMIF>{NAME} 	{
	if (angled_braces!=0){
		if (variables.find(yytext)==variables.end() && 
			arrays.find(yytext)==arrays.end()){
			std::map<std::string, char>::iterator it;
			std::cout << "Vectorul/variabila " << yytext << " nu este declarata ";
			std::cout << "@line" << yylineno << std::endl;
		}
		else if(variables.find(yytext)!=variables.end()){
			if (!key_negated){
				keys.push_back(new Symbol(variables[yytext]));
			}
			else{
				for(unsigned int i=0; i<alphabet.size(); ++i){
					if (alphabet[i]!=variables[yytext]){
						keys.push_back(new Symbol(alphabet[i]));
					}
				}
				key_negated = false;
			}
		}
		else if(arrays.find(yytext)!=arrays.end()){ 
			if (!key_negated){
				for(unsigned int i=0; i<arrays[yytext].size(); ++i){
					keys.push_back(new Symbol(arrays[yytext][i]));
				}
			}
			else{
				bool ok;
				for(unsigned int i=0; i<alphabet.size(); ++i){
					ok = true;
					for (unsigned int j=0; j<arrays[yytext].size(); ++j){
						if (alphabet[i]==arrays[yytext][j]){
							ok = false;
						}
					}
					if (ok){
						keys.push_back(new Symbol(alphabet[i]));
					}
				}
				key_negated = false;
			}
		}
	}
} 
<TURING_RAMIF>([ ]*->[ ]*) 	{}
<TURING_RAMIF>> 	{ angled_braces--; }
 /* Declararea unei variable locale */
<TURING_RAMIF>{SYMBOL}/@		{ 
	last_cell = new TuringCell;
	local_variable_name = yytext;
	BEGIN(LOCAL_VARIABLE); 
} 
<TURING_RAMIF>{SYMBOL}	{	
	if (curly_braces==1){
		if (key_negated){
			Symbol *key = new Symbol();
			for (unsigned int i=0; i<alphabet.size(); i++){
				if (alphabet[i]!=yytext[0]){
					key->addChar(alphabet[i]);	
				}
			}
			keys.push_back(key);
			key_negated = false;
		}
		else {
			keys.push_back(new Symbol(yytext[0]));
		}
	}
}
<TURING_RAMIF>"}"[ ]*->[ ]*	{ curly_braces--; }
<TURING_RAMIF>{NAME}/@		{ last_name = yytext; BEGIN(TURING_NAME); }
<TURING_RAMIF>"[" { 
	if (curly_braces!=0){
		std::cout << "Acoladele nu sunt balansate/ Lipseste '->' "; 
		std::cout << "@line" << yylineno << std::endl;
		return 1;
	}
	else {
		if (last_name.length()!=0){
			last_cell->setName(last_name);
			last_name = "";
		} 
		BEGIN(TURING_ACTION);
	}
}

<TURING_RAMIF>&		{ BEGIN(TURING_LINK); }
<TURING_RAMIF>")" 	{
	simple_braces--;
	saved_states.pop();
	if (simple_braces==0){
		BEGIN(TURING);
	}
	else {
		BEGIN(TURING_RAMIF);
	}
}

<TURING_RAMIF>,			{
	if (curly_braces==0){
		std::cout << "Simbol neasteptat " << yytext; 
		std::cout << " @line" << yylineno << std::endl;
	}
}

 /* Sare peste caracterele neimportante */
<TURING_RAMIF>[;\n\t ]	{}

 /* Avem un ciclu in masina Turing. Trebuie facuta legatura catre o stare */ 
 /* care deja exista */ 
<TURING_LINK>{NAME} { 
	TuringCell *cell = pmachine->getDescendantByName(yytext); 
	cell->setAsLink();
	machine->setDefaultNext(cell);
}
<TURING_LINK>[ ] 	{ 
	if (simple_braces!=0){
		BEGIN(TURING_RAMIF);
	}
	else {
		BEGIN(TURING);
	}
}

<TURING>;;			{
	turing_machines[machine_name] = pmachine;
	local_variables.clear();
	BEGIN(INITIAL);
}
<TURING>[.\n\t ]	{}

%%


int main(int argc, char** argv){
	std::string name, band, output;
	TuringCell *turing_machine = NULL;
	int position;
	if (argc < 4){
		std::cout<< "Mod rulare: ./mtx fis_in masina_turing banda" << std::endl;
		return 1;
	}
	yyin = fopen(argv[1], "r");
	name = std::string(argv[2]); 
	band = std::string(argv[3]);
	yylex();	
	if (turing_machines.find(name)==turing_machines.end()){
		// Masina data ca parametru nu exista in fisierul de intrare
		std::cout << "Masina " << name << " nu e declarata in " << argv[1];
		std::cout << "." << std::endl;
		return 1;
	}
	turing_machine = turing_machines[name];
	extendInput(band);
	// Determinam pozitia de inceput a capului de citire
	position = startingPosition(band);
	if (position==-1){
		std::cout << "Banda de intrare trebuie sa contina caracterul >" << std::endl;
		return 1;
	}
	// Curatam banda de caracterul '>'
	clearInput(band);
	// Executam masina 
	output = executeMachine(turing_machine, band, position);
	// Curatam banda de caracterele '#' in exces
	trimOutput(output, position);
	// Afisam rezultatul
	std::cout << output << std::endl;
	return 0;
}


