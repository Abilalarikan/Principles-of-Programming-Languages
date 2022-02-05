%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

int linenum=1;
%}
%%

[A-Z][A-Za-z]*  {yylval.str = strdup(yytext); return NONTERM;}
[a-z][A-Za-z]*  {yylval.str = strdup(yytext); return TERM;}
"<"             {yylval.str = strdup(yytext); return OPEN;}
">"	            {yylval.str = strdup(yytext); return CLOSE;}
"->"            {yylval.str = strdup(yytext); return ARROW;}
";"             {yylval.str = strdup(yytext); return SEMICLN;}
" "|"\t"        return WS;
\n	linenum++;
. {}

[ \t]+
%%


