#include "TuringCell.h"
#include <iostream>
#include <algorithm>
#include <string.h> 

/* Constructorul implicit. Nu se cunoaste nimic despre casuta */
TuringCell::TuringCell() : 
	name(""), 
	action('N'), 
	symbol(NULL),
	machine_name(""),
	is_link(false),
	negated(false) {
	
}

/* Constructor explicit */
TuringCell::TuringCell(char *name, char action, char character){
	setName(name);
	setAction(action);
	setSymbol(character);
	is_link = false;
	negated = false;
}

/* Contructorul pentru cazul in care casuta reprezinta o masina Turing*/
TuringCell::TuringCell(char* machine_name): 
	name(""), 
	action('N'), 
	symbol(NULL) {
	this->machine_name = std::string(machine_name);
}


TuringCell::~TuringCell(){
}

bool TuringCell::isFinalState(){
	return next_cells.empty();
}

void TuringCell::setName(char *name){
	this->name = std::string(name);
}

void TuringCell::setName(std::string name){
	this->name = name; 
}

std::string TuringCell::getName(){
	return name;
}

void TuringCell::setAction(char action){
	this->action = action;
}

char TuringCell::getAction(){
	return action;
}

void TuringCell::setSymbol(char character){
	this->symbol = new Symbol(character);
}

void TuringCell::setSymbol(Symbol *symbol){
	this->symbol = symbol;
}

Symbol* TuringCell::getSymbol(){
	return symbol;
}

/* Adauga o stare "fiu" care este aleasa daca pe banda se afla simbolul 
   asociat dat ca parametru. */ 
void TuringCell::addNext(Symbol *symbol, TuringCell *next){
	next_cells_symbols.push_back(symbol);
	next_cells.push_back(next);
}

/* Obtine starea urmatoare pe baza un simbol. Daca o stare asociata acelui 
   simbol nu exista atunci functia va returna NULL */
TuringCell* TuringCell::getNext(Symbol symbol){
	std::vector<Symbol*>::iterator it;
	std::vector<TuringCell*>::iterator itc;
	for(it=next_cells_symbols.begin(), itc=next_cells.begin(); 
		it!=next_cells_symbols.end() && itc!=next_cells.end(); ++it, ++itc){
		if (**it==symbol){
			return *itc;
		}
	}
	
	return NULL;
}

/* Sterge o stare asociata unui simbol */ 
void TuringCell::removeNext(Symbol symbol){
	for(unsigned int i=0; i<next_cells_symbols.size(); ++i){
		if (*next_cells_symbols[i]==symbol){
			next_cells_symbols.erase(next_cells_symbols.begin()+i);
			next_cells.erase(next_cells.begin()+i);
		}
	}
}

/* Obtine starea urmatoare pe baza unui simbol. Functia se foloseste in cazul 
   in care se asteapta ca una din chei sa fie cheie multipla si se doreste
   setarea ca cheie default a unui caracter din simbol. Tocmai prin varibila 
   booleana setDefault se specifica daca se doreste modificarea valorii default
   sau nu */
TuringCell* TuringCell::getNext(Symbol symbol, bool setDefault){
	
	std::vector<Symbol*>::iterator its;
	std::vector<TuringCell*>::iterator itc;
	for (its=next_cells_symbols.begin(), itc=next_cells.begin();
		 its!=next_cells_symbols.end() && itc!=next_cells.end(); ++its, ++itc){
		if ((*its)->isMultiple()){
			if ((*its)->containsChar(symbol.getDefault())){
				if (setDefault){
					(*its)->setDefault(symbol.getDefault());
				}
				return *itc;
			}
		}
	}
	// Daca nu s-a gasit o celula multipla care sa corespunda 
	// simbolui dat ca parametru se urmeaza procedura obisnuita 
	// in care nu se tine cont de tipul simbolului
	return getNext(symbol);
}

/* Seteaza ca starea default pe cea data ca parametru */
void TuringCell::setDefaultNext(TuringCell *next){
	
	TuringCell *next_cell = getNext(Symbol());
	if (next_cell!=NULL){
		removeNext(Symbol());
		
	}
	next_cells_symbols.push_back(new Symbol());
	next_cells.push_back(next);
}

/* Are sau nu stare default */
bool TuringCell::hasDefaultNext(){
	return (getNext(Symbol()) != NULL);
}

/* Getter starea default */
TuringCell* TuringCell::getDefaultNext(){
	return getNext(Symbol());
}

int TuringCell::getNextCellsNumber(){
	return next_cells.size();
}

void TuringCell::setAsLink(){
	is_link = true;
}

void TuringCell::toggleNegated(){
	negated = !negated;
}

bool TuringCell::isNegated(){
	return negated;
}

/* Obtine un copil al casutei curente dupa numele dat. Vectorul de celule 
   vizitate va fi folosit pentru linkuri. Acestea vor fi vizitate doar o singura
   data pentru a evita recursivitatea la infinit */ 
TuringCell* TuringCell::getDescendantByName(
	char *name, 
	std::vector<std::string> &visited){
	
	if (this->name==std::string(name)){
		return this;
	}
	else {
		TuringCell* returnedCell = NULL;
		std::vector<TuringCell*>::iterator it;
		std::vector<std::string>::iterator it2;
		bool ok;
		for (it=next_cells.begin(); it!=next_cells.end(); ++it){
			// In cazul in care urmatoarea casuta este link si a mai 
			// fost vizitata cel putin o data inainte nu se mai intra 
			// in recursivitate in acesta.
			ok = false;
			if ((*it)->is_link){
				// Avem link
				it2 = find(visited.begin(), visited.end(), (*it)->name);
				if (it2==visited.end()){
					ok = true;
					visited.push_back((*it)->name);
				}
			}
			else{
				// Nu avem link
				ok = true;
			}
			if (ok){
				// Daca e ok intra in recursivitate
				returnedCell = (*it)->getDescendantByName(name, visited);
				if (returnedCell!=NULL){
					return returnedCell;
				}
			}
		}
		
		if (next_cells.size()==0){
			return NULL;
		}
		return returnedCell;
	}
}

TuringCell* TuringCell::getDescendantByName(char *name){
	std::vector<std::string> visited; 
	return getDescendantByName(name, visited);
}

void TuringCell::setMachineName(char *name){
	machine_name = std::string(name);			
}

bool TuringCell::isMachine(){
	return (machine_name!="");
}

std::string TuringCell::getMachineName(){
	return machine_name;
}

/* Afiseaza celula de fata. */
void TuringCell::printCell(){
	if (isMachine()){
		std::cout << "[" << machine_name << "]" ;
	}
	else {
		if (name!=""){
			std::cout << "[" << name << "@";
		}
		else {
			std::cout << "[";
		}
	
	
		if (action=='N' && symbol!=NULL){ 
			std::cout << symbol->getDefault() << "]" << " ";
		}
		else if (symbol==NULL){
			if (action!='N'){
				std::cout << action << "]" << " ";
			}
			else {
				std::cout << "]";
			}
		}
		else { 
			if (negated){
				std::cout << action <<  "(!" << symbol->getDefault() << ")]";
			}
			else{
				std::cout <<  action << "(" << symbol->getDefault() << ")] ";
			}
		}
	}
}

/* Afiseaza "arborele" intregii masini Turing care porneste din casuta curenta */
void TuringCell::printTuringMachine(int level){
	std::vector<TuringCell*>::iterator it;
	for (int i=0; i<level; i++){
		std::cout << "  ";
	}
	printCell();
	if (next_cells.size()>1 || (next_cells.size()==1 && !hasDefaultNext())){
		level++;
		std::cout << std::endl;
	}
	if (level<2){
		for (it=next_cells.begin(); it!=next_cells.end(); ++it){
			(*it)->printTuringMachine(level);
		}
	}
	if (next_cells.size()==0){
		std::cout << std::endl;
	}
}

/* Functia ambalaj pentru cea dinainte */
void TuringCell::printTuringMachine(){
	printTuringMachine(0);
}

/* Afiseaza toate starile "fiu" alea starii curente */
void TuringCell::printNext(){
	std::vector<Symbol*>::iterator it;
	for (it=next_cells_symbols.begin(); it!=next_cells_symbols.end(); ++it){
		std::cout << (*it)->getDefault() << " ";
	}
}
