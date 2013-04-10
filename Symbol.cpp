#include "Symbol.h" 

Symbol::Symbol() : default_char('\0'), unique_key("") {
}

Symbol::Symbol(char character) {
	characters.push_back(character);
	unique_key = ""; 
	unique_key += character;
	default_char = character;
}

Symbol::~Symbol(){
}

void Symbol::addChar(char character){
	characters.push_back(character);
	unique_key += character;
}

void Symbol::setDefault(char character){
	default_char = character;
}

bool Symbol::containsChar(char character){
	for(unsigned int i=0; i<characters.size(); ++i){
		if (characters[i]==character){
			return true;
		}
	}
	return false;
}

/* Getter caracter default. Este caracterul default folosit de simbol in 
   momentul apelarii metodei */
char Symbol::getDefault() const{
	return default_char;
}

/* Afiseaza toate caracterele din simbol */
std::string Symbol::printAll(){
	std::string output="";
	for(unsigned int i=0; i<characters.size(); ++i){
		output += characters[i];
		output += " ";

	}
	return output;
}

void Symbol::removeDefault(){
	default_char = '\0';
}

/* Confirma daca este un simbol alcatuit din caractere multiple sau nu */
bool Symbol::isMultiple(){
	return (characters.size() > 1);
}

bool operator==(const Symbol& sym1, const Symbol& sym2){
	return sym1.unique_key == sym2.unique_key;
}
bool operator<(const Symbol& sym1, const Symbol& sym2){
	return sym1.unique_key < sym2.unique_key;
}
