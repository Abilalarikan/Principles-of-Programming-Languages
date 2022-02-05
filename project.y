%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <string.h>
	#include <vector>
	#include <map>
	#include <queue>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);
	extern int linenum;
	
	queue<string> left_control;
	queue<int> lengths;
	
	map<string,int> rules;
	int rule_number=0;
	int error_control;
	
	
	int left_flag=0;
	int left_counter=0;
	vector<string>  left_vector;
	
	string output="";
	
	string left_recursion(){
		string result="";
		for(int i=left_counter+2;i<left_vector.size();i++){
			result+=left_vector[0]+" -> "+left_vector[i]+" "+left_vector[1]+"\n";
		}
		result+=left_vector[1]+" -> epsilon\n";
		for(int i=2;i<left_counter+2;i++){
			result+=left_vector[1]+" -> "+left_vector[i]+" "+left_vector[1]+"\n";
		}
		
		left_flag=0;
		left_counter=0;
		left_vector.clear();
		
		return result;
	}
	
	void reverse_left_recursion(){
		while(!left_control.empty()){
			if(left_control.front()==left_vector[0]){
				left_control.pop();
				left_vector.push_back(left_control.front());
				left_control.pop();
				output=output.substr(0,output.length()-lengths.front());
				lengths.pop();
			}
			else{
				left_control.pop();
				left_control.pop();
				lengths.pop();
			}
				
		}
		while(!left_control.empty())
			left_control.pop();
		while(!lengths.empty())
			lengths.pop();
		
	}
%}

%union
{
	char * str;
}
%token WS 
%token<str> NONTERM TERM OPEN CLOSE ARROW SEMICLN 
%type<str> symbol symbols nonterminal ws
%%

program:
	rule
	|
	rule program
    ;

rule:
	nonterminal ws ARROW ws nonterminal ws symbols SEMICLN{
		if(rules[string($1)]==0){
			rules[string($1)]=++rule_number;
			error_control=rule_number;
		}
		else{
			if(rules[string($1)]<error_control){
				cout<<"In line "<<linenum<<", nonterminal "<<string($1)
				<<" is at the wrong place"<<endl;
				exit(0);
			}	
		}
			
		string nonterm1=string($1);
		string nonterm2=string($5);
		if(nonterm1==nonterm2){//left recursion
			if(left_flag==0){
				left_flag=1;
				string str=string($1);
				left_vector.push_back(str);
				str[str.length()-1]='2';
				str+=">";
				left_vector.push_back(str);
				left_vector.push_back(string($7));
				left_counter++;
				reverse_left_recursion();
			}
			else{
				if(nonterm1==left_vector[0]){
					left_vector.push_back(string($7));
					left_counter++;
				}
				else{
					output+=left_recursion();
					left_flag=1;
					string str=string($1);
					left_vector.push_back(str);
					str[str.length()-1]='2';
					str+=">";
					left_vector.push_back(str);
					left_vector.push_back(string($7));
					left_counter++;
				}
			}
		}
		else{
			if(left_flag==1){
				if(nonterm1==left_vector[0])
					left_vector.push_back(string($5)+string($6)+string($7));
				
				else{
					output+=left_recursion();
					string str=string($1)+string($2)+string($3)+string($4)+
							string($5)+string($6)+string($7)+"\n";
					output+=str;
					lengths.push(str.length());
					left_control.push(string($1));
					left_control.push(string($5)+string($6)+string($7));
				}
			}
			else{
				string str=string($1)+string($2)+string($3)+string($4)+
							string($5)+string($6)+string($7)+"\n";
				output+=str;
				lengths.push(str.length());
				left_control.push(string($1));
				left_control.push(string($5)+string($6)+string($7));
			}
				
		}	
	}
	|
	nonterminal ws ARROW ws TERM ws symbols SEMICLN{
		if(rules[string($1)]==0){
			rules[string($1)]=++rule_number;
			error_control=rule_number;
		}
		else{
			if(rules[string($1)]<error_control){
				cout<<"In line "<<linenum<<", nonterminal "<<string($1)
				<<" is at the wrong place"<<endl;
				exit(0);
			}		
		}
		
		if(left_flag==1){
			string nonterm=string($1);
			if(nonterm==left_vector[0])
				left_vector.push_back(string($5)+string($6)+string($7));
				
			else{
				output+=left_recursion();
				string str=string($1)+string($2)+string($3)+string($4)+
						string($5)+string($6)+string($7)+"\n";
				output+=str;
				lengths.push(str.length());
				left_control.push(string($1));
				left_control.push(string($5)+string($6)+string($7));
			}
		}
		else{
			string str=string($1)+string($2)+string($3)+string($4)+
					string($5)+string($6)+string($7)+"\n";
			output+=str;
			lengths.push(str.length());
			left_control.push(string($1));
			left_control.push(string($5)+string($6)+string($7));	
		}
			
	}
    ;

symbols:
	{$$=strdup("");}
	|
	symbol ws symbols{
		string combined=string($1)+string($2)+string($3);
		$$=strdup(combined.c_str());
	}
    ;
	
symbol:
	nonterminal{$$=strdup($1);}
	|
	TERM{$$=strdup($1);}
	;
	
nonterminal:
	OPEN NONTERM CLOSE {
		string combined=string($1)+string($2)+string($3);
		$$=strdup(combined.c_str());
	}
	|
	NONTERM CLOSE{
		cout<<"missing < symbol in line "<<linenum<<endl;
		exit(0);
	}
	|
	OPEN NONTERM{
		cout<<"missing > symbol in line "<<linenum<<endl;
		exit(0);
	}

ws:
	{$$=strdup("");}
	|
	WS ws {$$=strdup(" ");}
	;

%%

void yyerror(string s){
	cerr<<"syntax error at line "<<linenum<<endl;
	exit(0);
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
	
	if(left_flag==1)
		output+=left_recursion();
	
	cout<<output;
    return 0;
}
