const TIPO_OPERACION = require("../../controller/Enum/TipoOperaciones");
const TIPO_VALOR = require("../../controller/Enum/TipoValores");
const TIPO_INSTRUCCION = require("../../controller/Enum/TipoInstrucciones");
const TIPO_DATO = require("../../controller/Enum/Tipados");
const ValorExpresion = require("./ValorExpresion");
const Aritmetica = require("./Aritmetica");
const Relacional = require("./Relacional");
const Logica = require("./Logica");

function Operacion(_expresion, _ambito) {
    if (_expresion.tipo === TIPO_VALOR.DOBLE || _expresion.tipo === TIPO_VALOR.BOOLEANO ||
        _expresion.tipo === TIPO_VALOR.CADENA || _expresion.tipo === TIPO_VALOR.IDENTIFICADOR ||
        _expresion.tipo === TIPO_VALOR.CARACTER || _expresion.tipo === TIPO_VALOR.ENTERO) {
        return ValorExpresion(_expresion, _ambito)
    }
    else if (_expresion.tipo === TIPO_OPERACION.SUMA || _expresion.tipo === TIPO_OPERACION.RESTA
        || _expresion.tipo === TIPO_OPERACION.MULTIPLICACION || _expresion.tipo === TIPO_OPERACION.DIVISION
        || _expresion.tipo === TIPO_OPERACION.POTENCIA || _expresion.tipo === TIPO_OPERACION.MODULO
        || _expresion.tipo === TIPO_OPERACION.NEGACION) {
        return Aritmetica(_expresion, _ambito)
    }
    else if (_expresion.tipo === TIPO_OPERACION.IGUALIGUAL || _expresion.tipo === TIPO_OPERACION.DIFERENTE ||
        _expresion.tipo === TIPO_OPERACION.MENOR || _expresion.tipo === TIPO_OPERACION.MENORIGUAL ||
        _expresion.tipo === TIPO_OPERACION.MAYOR || _expresion.tipo === TIPO_OPERACION.MAYORIGUAL) {
        return Relacional(_expresion, _ambito)
    }
    else if (_expresion.tipo === TIPO_OPERACION.OR || _expresion.tipo === TIPO_OPERACION.AND || _expresion.tipo === TIPO_OPERACION.NOT) {
        return Logica(_expresion, _ambito)
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.TERNARIO) {
        const { Ternario } = require("../../controller/Instruccion/If");
        return Ternario(_expresion, _ambito)
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.CASTEO) {
        const { Casteo } = require("../Funciones/Reservadas");
        return Casteo(_expresion, _ambito)
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.ACCESO) {
        switch (_expresion.tipo_dato) {
            case TIPO_DATO.VECTOR:
                const { AccesoVector } = require("../Operacion/Acceso");
                return AccesoVector(_expresion, _ambito);
            case TIPO_DATO.LISTA:
                const { AccesoLista } = require("../Operacion/Acceso");
                return AccesoLista(_expresion, _ambito);
        }
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.TO_LOWER) {
        const { ToLower } = require("../Funciones/Reservadas");
        return ToLower(_expresion, _ambito);
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.TO_UPPER) {
        const { ToUpper } = require("../Funciones/Reservadas");
        return ToUpper(_expresion, _ambito);
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.LENGTH) {
        const { Length } = require("../Funciones/Reservadas");
        return Length(_expresion, _ambito);
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.TRUNCATE) {
        const { Truncate } = require("../Funciones/Reservadas");
        return Truncate(_expresion, _ambito);
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.ROUND) {
        const { Round } = require("../Funciones/Reservadas");
        return Round(_expresion, _ambito);
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.TYPEOF) {
        const { TypeOf } = require("../Funciones/Reservadas");
        return TypeOf(_expresion, _ambito);
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.TOSTRING) {
        const { ToString } = require("../Funciones/Reservadas");
        return ToString(_expresion, _ambito);
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.TOCHARLIST) {
        const { ToCharList } = require("../Funciones/Reservadas");
        return ToCharList(_expresion, _ambito);
    }
    else if (_expresion.tipo === TIPO_INSTRUCCION.LLAMADA) {
        const Start = require("../../controller/Instruccion/Start");
        var retorno = Start(_expresion, _ambito);
        if (retorno.err) return retorno;
        if (retorno.retorno == null)
            return { err: `Error: El método '${_expresion.nombre}' no retorna ningún valor.\nLínea: ${_expresion.linea} Columna: ${_expresion.columna}.\n` };
        if (retorno.retorno != null) {
            if (retorno.retorno.retorno) {
                retorno.cadena = retorno.retorno.cadena;
                retorno.retorno = retorno.retorno.retorno;
            }
        }
        return retorno;
    }
    else {
        return { err: `Error. Expresión no procesada.\nLínea: ${_expresion.linea} Columna: ${_expresion.columna}\n` };
    }
}

module.exports = Operacion