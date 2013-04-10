#include "Util.h"

/* Functii utile pentru executarea Masinii Turing */

/* Extinde banda masinii Turing la stanga si la dreapta cu INF(255). 
   Desi masina Turing are banda infinita la stanga si la dreapta in 
   practica trebuie sa ne limitam la un numar foarte mare */
void extendInput(std::string& input){
	input = std::string(INF, '#') + input + std::string(INF,'#');
}

/* Returneaza pozitia initiala a capului de citire/scriere pe banda */
int startingPosition(std::string input){
	return input.find('>');
}

/* Sterge din sirul de intrare caracterul '>' pentru ca acesta nu este 
   necesar in prelucrarea propriu-zisa, ci este nevoie de el doar la 
   inceput pentru a afla pozitia capului de citire */
void clearInput(std::string &input){
	int position = input.find('>');
	input.erase(input.begin()+position, input.begin()+position+1);
}

/* Pregatim stringul pentru afisare, asa cum este cerut in enunt. Dupa 
   executarea masinii sirul va avea la sfarsit un numar de foarte mare 
   de caractere '#' si va lipsi caracterul '>'.*/
void trimOutput(std::string &output,int position){	
	size_t end = 0, begin = 0;
	output.insert(output.begin()+position, '>');
	end = output.find_last_not_of("#");
	output.erase(end+2);
	begin = output.find_first_not_of("#");
	if (begin-1>0){
		output.erase(output.begin(), output.begin()+begin-1);
	}
}

TuringCell* findMachineByName(std::string name){
	std::map<std::string, TuringCell*>::iterator it;
	for (it=turing_machines.begin(); it!=turing_machines.end(); it++){
		if (it->first==name){
			return it->second;
		}
	}
	return NULL;
}



/* Executa masina Turing data ca parametru pe sirul de intrare cu capul de 
   citire in pozitia data de variabila position. */
std::string executeMachine(TuringCell *machine, std::string input, int& position){ 
	std::string output = input;
	TuringCell *pmachine = machine, 
			   *rmachine = NULL;

	while (1){
		// Decidem ce se face la pasul curent
		if (machine->getAction()=='L'){
			if (machine->getSymbol()==NULL){
				// Avem o simpla mutare la stanga
				position--;
			}
			else{
				// Avem o mutare pana se intalneste un anumit caracter
				position--;
				if (machine->isNegated()){
					// Daca e negare atunci se muta pana gasim un caracter 
					// diferit de cel din starea masinii turing
					while(output[position]==(machine->getSymbol())->getDefault()){
						position--;
					}
				}
				else {
					while(output[position]!=(machine->getSymbol())->getDefault()){
						position--;
					}
				}	
			}
		}
		else if(machine->getAction()=='R'){
			if (machine->getSymbol()==NULL){
				// Avem o simpla mutare la dreapta
				position++;
			}
			else {
				position++;
				// Avem o mutare pana se intalneste un anumit caracter
				if (machine->isNegated()){
					// Negare
					while(output[position]==(machine->getSymbol())->getDefault()){
						position++;
					}
				}
				else {
					while(output[position]!=(machine->getSymbol())->getDefault()){
						position++;
					}
				}
			}
		}
		else if(machine->getAction()=='N'){
			if (machine->getSymbol()!=NULL){
				if ((machine->getSymbol())->getDefault()!='\0'){
					// Trebuie scris un caracter pe banda la pozitia curenta
					output[position] = (machine->getSymbol())->getDefault();
				}
			}
			else {
				// Desi casuta nu mai specifica nici un fel de actiune
				// este posibil ca acesta sa fie o masina. In aces caz 
				// se va reapela masina specificata in casuta.
				if (machine->isMachine()){
					rmachine = findMachineByName(machine->getMachineName());	
					output = executeMachine(rmachine, output, position);
				}
				else{
					if (machine->getNextCellsNumber()==0){
						break;
					}
				}
			
			}
		}
		
		
		// Decidem care va fi urmatoarea stare in care intra masina turing
		if (machine->getNextCellsNumber()==1 && machine->hasDefaultNext()){
			// exista doar o singura stare urmatoare
			machine = machine->getDefaultNext();
			
		}
		else { // Avem ramificatie 
			TuringCell *next_cell = machine->getNext(Symbol(output[position]), true);
			if (next_cell!=NULL){
				machine = next_cell;
			}
			else {
				// Nu mai exista nici o operatie ce poate fi aplicata 
				// sirului de pe banda masinii Turing
				break;
			}
		}
	}
	machine = pmachine;
	return output;
}
