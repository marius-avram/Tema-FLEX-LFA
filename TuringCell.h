#ifndef _TURING_CELL_
#define _TURING_CELL_
#pragma once 
#include <string> 
#include <vector> 
#include "Symbol.h" 

class TuringCell{
	private:
		// Numele casutei. Nu e necesar ca toate casutele sa aiba o denumire.
		std::string name; 
		// Poate fie L,R,N (LEFT, RIGHT, NONE)	
		char action; 
		// Simbolul ce va fi scris pe banda. In cazul in care nu se scrie 
		// nimic pe banda se foloseste caracterul '\0'
		Symbol* symbol; 
		// Casuta poate fi o alta masina Turing definita anterior 
		std::string machine_name;
		// Legaturile catre casutele vecine in care se poate 
		// se poate duce automatul. Poate exista o singura legatura 
		// neconditionata sau o ramificatie de legaturi, in acest caz 
		// alegerea depinde de valoarea de pe banda (simbolul). Nu am folosit 
		// un map simplu pentru ca trebuie modificate cheile, insa fara a le 
		// sterge complet din memorie.
		std::vector<Symbol*> next_cells_symbols;
		std::vector<TuringCell*> next_cells;
		// Casuta este sau nu este un link catre o alta casuta deja 
		// definita (in cazul unui ciclu in masina Turing)
		bool is_link; 
		// Caracterul este insotit de semnul exclamarii. Aceasta combinatie
		// este posibila doar in cazul in care exista si o actiune ce se 
		// executa asupra benzii.
		bool negated;
		
	public: 
		TuringCell();
		TuringCell(char *name, char action, char character);
		TuringCell(char* machine_name);
		virtual ~TuringCell();
		
		bool isFinalState();
		
		void setName(char *name);
		void setName(std::string name);
		std::string getName();
		
		void setAction(char action);
		char getAction();
		
		void setSymbol(char character);
		void setSymbol(Symbol *symbol);
		Symbol* getSymbol();
		
		void addNext(Symbol *symbol, TuringCell *next);
		TuringCell* getNext(Symbol symbol);
		void removeNext(Symbol symbol);
		TuringCell* getNext(Symbol symbol, bool setDefault);
		void setDefaultNext(TuringCell *cell); 
		bool hasDefaultNext();
		TuringCell* getDefaultNext();
		int getNextCellsNumber();
		
		void setAsLink();
		void toggleNegated();
		bool isNegated();
		
		void setMachineName(char *name);
		bool isMachine();
		std::string getMachineName();
		TuringCell* getDescendantByName(char *name);
		TuringCell* getDescendantByName(char *name, 
										std::vector<std::string> &visited);
		void printCell();
		void printTuringMachine(int level);
		void printTuringMachine();
		void printNext();
};
#endif 
