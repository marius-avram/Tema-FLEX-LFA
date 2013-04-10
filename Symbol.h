#ifndef _SYMBOL_H_
#define _SYMBOL_H_
#include <vector>
#include <string>

class Symbol{
	private:
		// Lista cu toate caracterele prin care se poate 
		// reprezenta simbolul de fata
		std::vector<char> characters;
		// Desi un simbol poate fi reprezentat prin mai multe 
		// caractere poate fi ales la un moment dat doar unul 
		// dintre acestea. Daca nu e ales nici unul, default 
		// este '\0'
		char default_char;
		// Cheia unica obtinuta prin concatenarea tuturor caracterelor 
		// din vectorul characters. Utila pentru a compara doua simboluri 
		// ce sunt definite prin mai multe caractere.
		std::string unique_key;
	
	public:
		Symbol();
		Symbol(char chararacter);
		virtual ~Symbol();
		void addChar(char character);
		void setDefault(char character);
		bool containsChar(char character);
		char getDefault() const;
		void removeDefault();
		bool isMultiple();
		std::string printAll();
		friend bool operator==(const Symbol& sym1, const Symbol& sym2);
		friend bool operator<(const Symbol& sym1, const Symbol& sym2);
};


#endif
