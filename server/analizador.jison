
%{
	var cadena = '';
	var errores = [];
%}
%lex

%options case-insensitive
%x string

%%
//Expresiones 
\s+                   				// Blancos

"//".*								// FindeLinea

[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/]	// Multilinea


"double"             	return 'doubleeee'
"int"             		return 'iiiintt'
"boolean"              	return 'boooleaan'
"char"             		return 'chhhaaar'
"string"				return 'striiiinnng'
"dynamiclist"					return 'listaaad'
"new"					return 'neeeeew'
"append"					return 'apeeeennnd' //apeeeennnd
"getvalue"				return 'gvaaaall'

"if"					return 'iffffff'

"else"					return 'elseeeee'



"switch"				return 'swiiiitchhhh'

"case"					return 'cassssseee'
"break"					return 'breeeeackkk'

"while"               	return 'whhileee'

"for"					return 'fffooorr'
"do"					return 'ddoooo'

"default"				return 'defauuultt'
"continue"				return 'conntinuuee'

"return"				return 'retuuuurnn'

"void"					return 'voooiiddd'
"++"					return 'incremento'

"--"					return 'decremento'

"writeline"					return 'writelineee'
"toLower"				return 'twolower'
"toUpper"				return 'twouppeer'

"length"				return 'leeengthhh'


"truncate"				return 'truncaaateee'
"round"					return 'roooouuund'

"typeof"				return 'tyyyyperoof'
"toString"				return 'twostr'

"toCharArray"			return 'twochhaararray'
"start"					return 'staaaart' 
"with"					return 'wiiithh'
"setvalue"				return 'svaaal'
"true"                	return 'true'
"false"               	return 'false'
//Operadores Logicos
"||"                   	return 'or'
"&&"                   	return 'and'
"!="                   	return 'diferente'
"=="                   	return 'igualigual'
"!"                   	return 'not'
"="						return 'igual'
"<="                   	return 'menorigual'
">="					return 'mayorigual'
">"                   	return 'mayor'
"<"                   	return 'menor'
","                   	return 'coma'
";"                   	return 'ptcoma'
"."						return 'punto'
":"						return 'dospuntos'
"{"                   	return 'labre'
"}"                   	return 'lcierra'
//Operadores aritmeticos
"*"                   	return 'multi'
"/"                   	return 'div'
"-"                   	return 'menos'
"+"                   	return 'suma'
"^"                   	return 'exponente'
"%"                   	return 'modulo'
"("                   	return 'pabre'
")"                   	return 'pcierra'
"?"						return 'interrogacion'
"["						return 'cabre'
"]"						return 'ccierra'
// id
([a-zA-Z])([a-zA-Z0-9_])* return 'id'
// Cualquier caracter
[']\\\\[']|[']\\\"[']|[']\\\'[']|[']\\n[']|[']\\t[']|[']\\r[']|['].?[']	return 'caracter'
// Decimales
[0-9]+("."[0-9]+)+\b	return 'doble'
// Enteros
[0-9]+					return 'entero'


["]						{ cadena = ''; this.begin("string"); }



<string>[^"\\]+			{ cadena += yytext; }
<string>"\\\""			{ cadena += "\""; }

<string>"\\n"			{ cadena += "\n"; }

<string>\s				{ cadena += " ";  }

<string>"\\t"			{ cadena += "\t"; }

<string>"\\\\"			{ cadena += "\\"; }

<string>"\\\'"			{ cadena += "\'"; }

<string>"\\r"			{ cadena += "\r"; }

<string>["]				{ yytext = cadena; this.popState(); return 'cadena'; }

<<EOF>>               	return 'EOF'
.                     	{ errores.push({ tipo: "Léxico", error: yytext, linea: yylloc.first_line, columna: yylloc.first_column+1 }); return 'INVALID'; } 

/lex
%{
	const TIPO_OPERACION	= require('./controller/Enum/TipoOperaciones');

	const TIPO_VALOR 		= require('./controller/Enum/TipoValores');

	const TIPO_DATO			= require('./controller/Enum/Tipados');

	const INSTRUCCION		= require('./controller/Instruccion/Instruccion');
%}

//Precedencias 

%left 'interrogacion'

%left 'or'

%left 'and'

%right 'not'

%left 'igualigual' 'diferente' 'menor' 'menorigual' 'mayor' 'mayorigual'

%left 'suma' 'menos'

%left 'multi' 'div' 'modulo'

%left 'exponente'

%left 'incremento','decremento'

%left umenos

%left 'pabre'

%start inicio

//Gramatica

%%

inicio: CONTENIDO EOF { retorno = { parse: $1, errores: errores }; errores = []; return retorno; }
	| error EOF { retorno = { parse: null, errores: errores }; errores = []; return retorno; }
;

CONTENIDO: CONTENIDO ENTCERO { if($2!=="") $1.push($2); $$=$1; }
		| ENTCERO {if($1!=="") $$=[$1]; else $$=[]; }
;

ENTCERO: FUNCIONBODY {$$=$1}
		| METODOBODY {$$=$1}
		| STARTBODY {$$=$1}
		| DEC_VAR {$$=$1}
		| VECT {$$=$1}
		| DEC_LIST {$$=$1}
;

FUNCIONBODY: TIPO id pabre pcierra labre INSTRUCCION lcierra { $$ = INSTRUCCION.nuevaFuncion($2, null, $6, $1, this._$.first_line, this._$.first_column+1) }
	
			| TIPO id pabre pcierra labre lcierra { $$ = INSTRUCCION.nuevaFuncion($2, null, [], $1, this._$.first_line, this._$.first_column+1) }
	
			| TIPO id pabre LISTADO_PARA pcierra labre INSTRUCCION lcierra { $$ = INSTRUCCION.nuevaFuncion($2, $4, $7, $1, this._$.first_line, this._$.first_column+1) }
	
			| TIPO id pabre LISTADO_PARA pcierra labre lcierra { $$ = INSTRUCCION.nuevaFuncion($2, $4, [], $1, this._$.first_line, this._$.first_column+1) }
	
	
			| TIPO id cabre ccierra pabre pcierra labre INSTRUCCION lcierra { $$ = INSTRUCCION.nuevaFuncion($2, null, $8, {vector: $1}, this._$.first_line, this._$.first_column+1) }
	
			| TIPO id cabre ccierra pabre pcierra labre lcierra { $$ = INSTRUCCION.nuevaFuncion($2, null, [], {vector: $1}, this._$.first_line, this._$.first_column+1) }
	
	
			| TIPO id cabre ccierra pabre LISTADO_PARA pcierra labre INSTRUCCION lcierra { $$ = INSTRUCCION.nuevaFuncion($2, $6, $9, {vector: $1}, this._$.first_line, this._$.first_column+1) }
	
			| TIPO id cabre ccierra pabre LISTADO_PARA pcierra labre lcierra { $$ = INSTRUCCION.nuevaFuncion($2, $6, [], {vector: $1}, this._$.first_line, this._$.first_column+1) }
	
	
			| TIPO_LIST id pabre pcierra labre INSTRUCCION lcierra { $$ = INSTRUCCION.nuevaFuncion($2, null, $6, {lista: $1}, this._$.first_line, this._$.first_column+1) }
	
			| TIPO_LIST id pabre pcierra labre lcierra { $$ = INSTRUCCION.nuevaFuncion($2, null, [], {lista: $1}, this._$.first_line, this._$.first_column+1) }
	
			| TIPO_LIST id pabre LISTADO_PARA pcierra labre INSTRUCCION lcierra { $$ = INSTRUCCION.nuevaFuncion($2, $4, $7, {lista: $1}, this._$.first_line, this._$.first_column+1) }
	
			| TIPO_LIST id pabre LISTADO_PARA pcierra labre lcierra { $$ = INSTRUCCION.nuevaFuncion($2, $4, [], {lista: $1}, this._$.first_line, this._$.first_column+1) }
	
			| TIPO error lcierra { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de función no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
	
	
			| TIPO cabre ccierra error lcierra { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de función no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
	
			| TIPO_LIST error lcierra { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de función no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

METODOBODY: voooiiddd id pabre pcierra labre INSTRUCCION lcierra { $$ = INSTRUCCION.nuevoMetodo($2, [], $6, this._$.first_line, this._$.first_column+1) }
			
			| voooiiddd id pabre pcierra labre lcierra { $$ = INSTRUCCION.nuevoMetodo($2, [], [], this._$.first_line, this._$.first_column+1) }
			
			| voooiiddd id pabre LISTADO_PARA pcierra labre INSTRUCCION lcierra { $$ = INSTRUCCION.nuevoMetodo($2, $4, $7, this._$.first_line, this._$.first_column+1) }
			
			
			
			| voooiiddd id pabre LISTADO_PARA pcierra labre lcierra { $$ = INSTRUCCION.nuevoMetodo($2, $4, [], this._$.first_line, this._$.first_column+1) }
			
			| voooiiddd error lcierra { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de método no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

STARTBODY: staaaart wiiithh id pabre pcierra ptcoma {$$ = INSTRUCCION.nuevoStart($3, null, this._$.first_line, this._$.first_column+1)}
	
		| staaaart wiiithh id pabre LISTAVALORES pcierra ptcoma {$$ = INSTRUCCION.nuevoStart($3, $5, this._$.first_line, this._$.first_column+1)}
	
		| staaaart wiiithh error ptcoma { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Llamada de start with no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

LISTADO_PARA: LISTADO_PARA coma PARAMETROS {$1.push($3); $$=$1;}
				| PARAMETROS {$$=[$1];}
;

PARAMETROS: TIPO id cabre ccierra {$$ = INSTRUCCION.nuevoParametro($2, {vector: $1}, this._$.first_line, this._$.first_column+1)}
			| TIPO_LIST id {$$ = INSTRUCCION.nuevoParametro($2, {lista: $1}, this._$.first_line, this._$.first_column+1)}
			| TIPO id {$$ = INSTRUCCION.nuevoParametro($2, $1, this._$.first_line, this._$.first_column+1)}
;

INSTRUCCION: INSTRUCCION INSCERO { if($2!=="") $1.push($2); $$=$1; }
			| INSCERO { if($1!=="") $$=[$1]; else $$=[]; }
;

INSCERO: DEC_VAR {$$=$1}

		| SENTENCIACONTROL {$$=$1}
	
		| SENTENCIACICLO {$$=$1}
	
		| VECT {$$=$1}
	
		| DEC_LIST {$$=$1}
	
		| SENTENCIATRANSFERENCIA {$$=$1}
	
		| LLAMADA ptcoma {$$=$1}
	
		| FWRITELINE {$$=$1}
	
		| error ptcoma { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de instrucción no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
	
		| error lcierra { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de instrucción no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

SENTENCIATRANSFERENCIA: breeeeackkk ptcoma { $$ = new INSTRUCCION.nuevoBreak(this._$.first_line, this._$.first_column+1) }
						| retuuuurnn EXP ptcoma { $$ = new INSTRUCCION.nuevoReturn($2, this._$.first_line, this._$.first_column+1) }
						| conntinuuee ptcoma { $$ = new INSTRUCCION.nuevoContinue(this._$.first_line, this._$.first_column+1) }
						| retuuuurnn ptcoma { $$ = new INSTRUCCION.nuevoReturn(null, this._$.first_line, this._$.first_column+1) }
;

SENTENCIACICLO: WHILE {$$=$1}
				| FOR {$$=$1}
				| DOWHILE {$$=$1}
;

WHILE: whhileee pabre EXP pcierra labre INSTRUCCION lcierra {$$ = new INSTRUCCION.nuevoWhile($3, $6, this._$.first_line,this._$.first_column+1)}
		| whhileee pabre EXP pcierra labre lcierra {$$ = new INSTRUCCION.nuevoWhile($3, [], this._$.first_line,this._$.first_column+1)}
		| whhileee error lcierra { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de ciclo While no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

FOR: fffooorr pabre DEC_VAR EXP ptcoma ACTUALIZACION pcierra labre INSTRUCCION lcierra {$9.push($6); $$ = new INSTRUCCION.nuevoFor($3, $4, $9, this._$.first_line,this._$.first_column+1)}
	| fffooorr pabre DEC_VAR EXP ptcoma ACTUALIZACION pcierra labre lcierra { $$ = new INSTRUCCION.nuevoFor($3, $4, [$6], this._$.first_line,this._$.first_column+1)}
	| fffooorr error lcierra { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de ciclo For no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

ACTUALIZACION: id igual EXP {$$ = INSTRUCCION.nuevaAsignacion($1, $3, this._$.first_line,this._$.first_column+1)}
 			| id incremento {
			$$ = INSTRUCCION.nuevaAsignacion($1,
			{ opIzq: { tipo: 'VAL_IDENTIFICADOR', valor: $1, linea: this._$.first_line, columna: this._$.first_column+1 },
  			opDer: { tipo: 'VAL_ENTERO', valor: 1, linea: this._$.first_line, columna: this._$.first_column+1 },
  			tipo: 'SUMA',
  			linea: this._$.first_line,
  			columna: this._$.first_column+1 }, this._$.first_line,this._$.first_column+1)
			}
			| id decremento {
			$$ = INSTRUCCION.nuevaAsignacion($1,
			{ opIzq: { tipo: 'VAL_IDENTIFICADOR', valor: $1, linea: this._$.first_line, columna: this._$.first_column+1 },
  			opDer: { tipo: 'VAL_ENTERO', valor: 1, linea: this._$.first_line, columna: this._$.first_column+1 },
  			tipo: 'RESTA',
  			linea: this._$.first_line,
  			columna: this._$.first_column+1 }, this._$.first_line,this._$.first_column+1)
			}
;

DOWHILE: ddoooo labre INSTRUCCION lcierra whhileee pabre EXP pcierra ptcoma {$$ = new INSTRUCCION.nuevoDoWhile($7, $3, this._$.first_line,this._$.first_column+1)}
		| ddoooo labre lcierra whhileee pabre EXP pcierra ptcoma {$$ = new INSTRUCCION.nuevoDoWhile($7, [], this._$.first_line,this._$.first_column+1)}
		| ddoooo error ptcoma { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de sentencia Do-While no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

SENTENCIACONTROL: CONTROLIF {$$=$1}
				| SWITCH {$$=$1}
;

CONTROLIF: IF {$$=$1}
	| IFELSE {$$=$1}
	| ELSEIF {$$=$1}
	| iffffff error lcierra { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de sentencia If no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

IF: iffffff pabre EXP pcierra labre INSTRUCCION lcierra { $$ = new INSTRUCCION.nuevoIf($3, $6, this._$.first_line,this._$.first_column+1) }
	| iffffff pabre EXP pcierra labre lcierra { $$ = new INSTRUCCION.nuevoIf($3, [], this._$.first_line,this._$.first_column+1) }
;

IFELSE: iffffff pabre EXP pcierra labre INSTRUCCION lcierra elseeeee labre INSTRUCCION lcierra { $$ = new INSTRUCCION.nuevoIfElse($3, $6, $10, this._$.first_line,this._$.first_column+1) }
		| iffffff pabre EXP pcierra labre lcierra elseeeee labre INSTRUCCION lcierra { $$ = new INSTRUCCION.nuevoIfElse($3, [], $9, this._$.first_line,this._$.first_column+1) }
		| iffffff pabre EXP pcierra labre INSTRUCCION lcierra elseeeee labre lcierra { $$ = new INSTRUCCION.nuevoIfElse($3, $6, [], this._$.first_line,this._$.first_column+1) }
		| iffffff pabre EXP pcierra labre lcierra elseeeee labre lcierra { $$ = new INSTRUCCION.nuevoIfElse($3, [], [], this._$.first_line,this._$.first_column+1) }
;

ELSEIF: iffffff pabre EXP pcierra labre INSTRUCCION lcierra elseeeee CONTROLIF { $$ = new INSTRUCCION.nuevoElseIf($3, $6, $9, this._$.first_line,this._$.first_column+1); }
		| iffffff pabre EXP pcierra labre lcierra elseeeee CONTROLIF { $$ = new INSTRUCCION.nuevoElseIf($3, [], $8, this._$.first_line,this._$.first_column+1); }
;

SWITCH: swiiiitchhhh pabre EXP pcierra labre CASESLIST DEFAULT lcierra { $$ = new INSTRUCCION.nuevoSwitch($3, $6, $7, this._$.first_line, this._$.first_column+1); }
		| swiiiitchhhh pabre EXP pcierra labre CASESLIST lcierra { $$ = new INSTRUCCION.nuevoSwitch($3, $6, null, this._$.first_line, this._$.first_column+1); }
		| swiiiitchhhh pabre EXP pcierra labre DEFAULT lcierra { $$ = new INSTRUCCION.nuevoSwitch($3, null, $6, this._$.first_line, this._$.first_column+1); }
		| swiiiitchhhh error lcierra { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de sentencia Swtich no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

CASESLIST: CASESLIST cassssseee EXP dospuntos INSTRUCCION { $1.push(new INSTRUCCION.nuevoCaso($3, $5, this._$.first_line, this._$.first_column+1)); $$=$1; }
		| CASESLIST cassssseee EXP dospuntos { $1.push(new INSTRUCCION.nuevoCaso($3, [], this._$.first_line, this._$.first_column+1)); $$=$1; }
		| cassssseee EXP dospuntos INSTRUCCION { $$ = [new INSTRUCCION.nuevoCaso($2, $4, this._$.first_line, this._$.first_column+1)]; }
		| cassssseee EXP dospuntos { $$ = [new INSTRUCCION.nuevoCaso($2, [], this._$.first_line, this._$.first_column+1)]; }
		| cassssseee error dospuntos { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de caso no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

DEFAULT: defauuultt dospuntos INSTRUCCION { $$ = new INSTRUCCION.nuevoCaso(null, $3, this._$.first_line, this._$.first_column+1); }
		| defauuultt dospuntos { $$ = new INSTRUCCION.nuevoCaso(null, [], this._$.first_line, this._$.first_column+1); }
;

DEC_VAR: TIPO id igual EXP ptcoma {$$ = INSTRUCCION.nuevaDeclaracion($2, $4, $1, this._$.first_line,this._$.first_column+1)}
	
		| TIPO id ptcoma {$$ = INSTRUCCION.nuevaDeclaracion($2, null, $1, this._$.first_line,this._$.first_column+1)}
	
		| id igual EXP ptcoma {$$ = INSTRUCCION.nuevaAsignacion($1, $3, this._$.first_line,this._$.first_column+1)}
	
		| id incremento ptcoma {
			$$ = INSTRUCCION.nuevaAsignacion($1,
			{ opIzq: { tipo: 'VAL_IDENTIFICADOR', valor: $1, linea: this._$.first_line, columna: this._$.first_column+1 },
  		
		  	opDer: { tipo: 'VAL_ENTERO', valor: 1, linea: this._$.first_line, columna: this._$.first_column+1 },
  	
	  		tipo: 'SUMA',
  	
	  		linea: this._$.first_line,
  	
	  		columna: this._$.first_column+1 }, this._$.first_line,this._$.first_column+1)
	
			}
		| id decremento ptcoma {
		
			$$ = INSTRUCCION.nuevaAsignacion($1,
		
			{ opIzq: { tipo: 'VAL_IDENTIFICADOR', valor: $1, linea: this._$.first_line, columna: this._$.first_column+1 },
  		
		  	opDer: { tipo: 'VAL_ENTERO', valor: 1, linea: this._$.first_line, columna: this._$.first_column+1 },
  		
		  	tipo: 'RESTA',
  		
		  	linea: this._$.first_line,
  		
		  	columna: this._$.first_column+1 }, this._$.first_line,this._$.first_column+1)
			}
		| TIPO error ptcoma { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de variable no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

VECT: TIPO id cabre ccierra igual neeeeew TIPO cabre EXP ccierra ptcoma { $$ = INSTRUCCION.nuevoVector($1, $7, $2, $9, null, null, this._$.first_line, this._$.first_column+1) }
	
		| TIPO id cabre ccierra igual labre LISTAVALORES lcierra ptcoma { $$ = INSTRUCCION.nuevoVector($1, null, $2, null, $7, null, this._$.first_line, this._$.first_column+1) }
	
		| id cabre EXP ccierra igual EXP ptcoma { $$ = INSTRUCCION.modificacionVector($1, $3, $6, this._$.first_line, this._$.first_column+1) }
	
		| TIPO  id cabre ccierra igual EXP ptcoma { $$ = INSTRUCCION.nuevoVector($1, null, $2, null, null, $6, this._$.first_line, this._$.first_column+1) }
	
		| TIPO cabre ccierra error ptcoma { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de vector no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

DEC_LIST: TIPO_LIST id igual neeeeew listaaad menor TIPO mayor ptcoma { $$ = INSTRUCCION.nuevaLista($1, $7, $2, null, this._$.first_line, this._$.first_column+1) }
		
		//| id punto pradd pabre EXP pcierra ptcoma { $$ = INSTRUCCION.modificacionLista($1, null, $5, this._$.first_line, this._$.first_column+1) }
		| apeeeennnd pabre id coma EXP pcierra ptcoma { $$ = INSTRUCCION.modificacionLista($3, null, $5, this._$.first_line, this._$.first_column+1) }


		| svaaal pabre id coma EXP coma EXP pcierra ptcoma { $$ = INSTRUCCION.modificacionLista($3, $5, $7, this._$.first_line, this._$.first_column+1) }

		//| id cabre cabre EXP ccierra ccierra igual EXP ptcoma { $$ = INSTRUCCION.modificacionLista($1, $4, $8, this._$.first_line, this._$.first_column+1) }


		| TIPO_LIST id igual EXP ptcoma { $$ = INSTRUCCION.nuevaLista($1, null, $2, $4, this._$.first_line, this._$.first_column+1) }
		| TIPO_LIST error ptcoma { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Declaración de lista no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

//TIPO: TIPO  {$$ = $1}
//;



TIPO_LIST: listaaad menor TIPO mayor {$$ = $3}
;

TIPO: TIPODATO {$$ = $1}
;

TIPODATO: striiiinnng {$$ = TIPO_DATO.CADENA}
	
		| iiiintt {$$ = TIPO_DATO.ENTERO}
	
		| doubleeee {$$ = TIPO_DATO.DOBLE}
	
		| chhhaaar {$$ = TIPO_DATO.CARACTER}
	
		| boooleaan {$$ = TIPO_DATO.BOOLEANO}
;


EXP: 	EXP suma EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.SUMA,this._$.first_line,this._$.first_column+1);}
	
			| EXP menos EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.RESTA,this._$.first_line,this._$.first_column+1);}
	
			| EXP multi EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.MULTIPLICACION,this._$.first_line,this._$.first_column+1);}
	
			| EXP div EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.DIVISION,this._$.first_line,this._$.first_column+1);}
	
			| EXP exponente EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.POTENCIA,this._$.first_line,this._$.first_column+1);}
	
			| EXP modulo EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.MODULO,this._$.first_line,this._$.first_column+1);}
	
			| menos EXP %prec umenos {$$= INSTRUCCION.nuevaOperacionBinaria($2, null, TIPO_OPERACION.NEGACION,this._$.first_line,this._$.first_column+1);}
	
			| pabre EXP pcierra {$$=$2}
	
			| EXP igualigual EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.IGUALIGUAL,this._$.first_line,this._$.first_column+1);}
	
			| EXP diferente EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.DIFERENTE,this._$.first_line,this._$.first_column+1);}
	
			| EXP menor EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.MENOR,this._$.first_line,this._$.first_column+1);}
	
			| EXP menorigual EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.MENORIGUAL,this._$.first_line,this._$.first_column+1);}
	
			| EXP mayor EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.MAYOR,this._$.first_line,this._$.first_column+1);}
	
			| EXP mayorigual EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.MAYORIGUAL,this._$.first_line,this._$.first_column+1);}
	
			| EXP or EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.OR,this._$.first_line,this._$.first_column+1);}
	
			| EXP and EXP {$$= INSTRUCCION.nuevaOperacionBinaria($1,$3, TIPO_OPERACION.AND,this._$.first_line,this._$.first_column+1);}
	
			| not EXP {$$= INSTRUCCION.nuevaOperacionBinaria($2, null, TIPO_OPERACION.NOT,this._$.first_line,this._$.first_column+1);}
	
			| cadena {$$ = INSTRUCCION.nuevoValor($1, TIPO_VALOR.CADENA, this._$.first_line,this._$.first_column+1)}
	
			| caracter {$$ = INSTRUCCION.nuevoValor($1.trim().substring(1, $1.length - 1), TIPO_VALOR.CARACTER, this._$.first_line,this._$.first_column+1)}
	
			| true {$$ = INSTRUCCION.nuevoValor($1.trim(), TIPO_VALOR.BOOLEANO, this._$.first_line,this._$.first_column+1)}
	
			| false {$$ = INSTRUCCION.nuevoValor($1.trim(), TIPO_VALOR.BOOLEANO, this._$.first_line,this._$.first_column+1)}
	
			| entero {$$ = INSTRUCCION.nuevoValor(Number($1.trim()), TIPO_VALOR.ENTERO, this._$.first_line,this._$.first_column+1)}
	
			| doble {$$ = INSTRUCCION.nuevoValor(Number($1.trim()), TIPO_VALOR.DOBLE, this._$.first_line,this._$.first_column+1)}
	
			//| id cabre cabre EXP ccierra ccierra { $$ = INSTRUCCION.accesoLista($1, $4, this._$.first_line, this._$.first_column+1) }

			| gvaaaall pabre id coma EXP pcierra { $$ = INSTRUCCION.accesoLista($3, $5, this._$.first_line, this._$.first_column+1) }


			| id cabre EXP ccierra { $$ = INSTRUCCION.accesoVector($1, $3, this._$.first_line, this._$.first_column+1) }
			| id {$$ = INSTRUCCION.nuevoValor($1.trim(), TIPO_VALOR.IDENTIFICADOR, this._$.first_line,this._$.first_column+1)}
			| CASTEO {$$=$1}
			| TERNARIO {$$=$1}
			| LLAMADA {$$=$1}
			| FUNCIONESRESERVADAS {$$=$1}
;

CASTEO: pabre TIPO pcierra EXP { $$ = new INSTRUCCION.nuevoCasteo($2, $4, this._$.first_line, this._$.first_column+1) }
;

TERNARIO: EXP interrogacion EXP dospuntos EXP { $$ = new INSTRUCCION.nuevoTernario($1, $3, $5, this._$.first_line, this._$.first_column+1) }
;

FUNCIONESRESERVADAS: FTOLOWER {$$=$1}
	
					| FTOUPPER {$$=$1}
	
					| FLENGTH {$$=$1}
	
					| FTRUNCATE {$$=$1}
	
					| FROUND {$$=$1}
	
					| FTYPEOF {$$=$1}
	
					| FTOSTRING {$$=$1}
	
					| FTOCHARARRAY {$$=$1}
;

FWRITELINE: writelineee pabre EXP pcierra ptcoma {$$ = new INSTRUCCION.nuevoImprimir($3, this._$.first_line,this._$.first_column+1)}
		| writelineee pabre pcierra ptcoma {$$ = new INSTRUCCION.nuevoImprimir(INSTRUCCION.nuevoValor("", TIPO_VALOR.CADENA, this._$.first_line,this._$.first_column+1), this._$.first_line,this._$.first_column+1)}
		| writelineee error ptcoma { $$ = ""; errores.push({ tipo: "Sintáctico", error: "Llamada a función imprimir no válida.", linea: this._$.first_line, columna: this._$.first_column+1 }); }
;

FTOLOWER: twolower pabre EXP pcierra {$$ = new INSTRUCCION.toLower($3, this._$.first_line,this._$.first_column+1)}
;

FTOUPPER: twouppeer pabre EXP pcierra {$$ = new INSTRUCCION.toUpper($3, this._$.first_line,this._$.first_column+1)}
;

FLENGTH: leeengthhh pabre EXP pcierra {$$ = new INSTRUCCION.nuevoLength($3, this._$.first_line,this._$.first_column+1)}
;

FTRUNCATE: truncaaateee pabre EXP pcierra {$$ = new INSTRUCCION.nuevoTruncate($3, this._$.first_line,this._$.first_column+1)}
;

FROUND: roooouuund pabre EXP pcierra {$$ = new INSTRUCCION.nuevoRound($3, this._$.first_line,this._$.first_column+1)}
;

FTYPEOF: tyyyyperoof pabre EXP pcierra {$$ = new INSTRUCCION.nuevoTypeOf($3, this._$.first_line,this._$.first_column+1)}
;

FTOSTRING: twostr pabre EXP pcierra {$$ = new INSTRUCCION.nuevoToString($3, this._$.first_line,this._$.first_column+1)}
;

FTOCHARARRAY: twochhaararray pabre EXP pcierra {$$ = new INSTRUCCION.nuevoToCharArray($3, this._$.first_line,this._$.first_column+1)}
;

LLAMADA: id pabre LISTAVALORES pcierra {$$ = INSTRUCCION.nuevaLlamada($1, $3, this._$.first_line, this._$.first_column+1)}
		| id pabre pcierra {$$ = INSTRUCCION.nuevaLlamada($1, [], this._$.first_line, this._$.first_column+1)}
;

LISTAVALORES: LISTAVALORES coma VALORES {$1.push($3); $$=$1;}
			| VALORES {$$=[$1];}
;

VALORES: EXP {$$=$1}
;
