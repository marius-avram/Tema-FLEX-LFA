#ifndef _UTIL_H_
#define _UTIL_H_
#include <string> 
#include "TuringCell.h"

#define INF 255

void extendInput(std::string& input);

int startingPosition(std::string input);

void clearInput(std::string &input);

void trimOutput(std::string &output,int position);

TuringCell* findMachineByName(std::string name);

std::string executeMachine(TuringCell *machine, std::string input, int& position);


#endif
