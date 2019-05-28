/*
 * Ejemplo 6.2.10.
 * Se busca simplificar la notacion de las gramaticas libres de contexto
 * Segun lo investigado, hay otra manera de expresar las gramaticas
 * Se implementa logica que permite utilizar los caminos como nombres
 * Compatible con sinonimos
 * Se investiga como manejar diferencias de palabras por capitalizacion
 * Cambios de optimizacion de codigo
 * Fuente: https://www.cs.us.es/cursos/ia2-2004/temas/tema-03.pdf
 * Fuente: https://personal.us.es/fsoler/papers/05capgram.pdf
 * Esta version nueva se hace ya que la idea de cambiar minusculas ha
 * generado varios problemas
 * Se incluye la logica de interpretacion de oraciones
 * Se soluciona el problema de palabras compuestas
 * Se incluye la descomposicion de una oracion en gramaticas
 * Se hace compatible con Java mediante hechos
 */

% Base de datos
camino --> [[cartago], [san, jose], 25];
           [[alajuela], [heredia], 7];
           [[san, jose], [alajuela], 15];
           [[cartago], [tres, rios], 10].

establecimiento(masculino, singular) --> [supermercado];
                                         [universidad].

establecimiento_nombre(masculino, singular, [supermercado]) --> [automercado];
                                                               [mas,x,menos].
establecimiento_nombre(masculino, singular, [universidad]) --> [tec];
                                                               [tecnologico,de,costa,rica].
establecimiento_nombre(femenino, singular, [universidad]) --> [ucr];
                                                              [universidad,de,costa,rica].

% Todo primer elemento en los nodos es un origen
origen(S,_) :- camino([S|_],_).
% Todo segundo elemento en los nodos es un destino
destino(S,_) :- camino([_,S|_],_).
% Un origen o un destino son lugares
lugar --> origen; destino.

% Metodos necesarios
% Concatena dos listas
concatenar([], L, L).
concatenar([X|L1], L2, [X|L3]) :- concatenar(L1, L2, L3).

% Elimina el elemento L de una lista [H|T].
remove_elements(L, [H|T], R) :-
    delete(L, H, R1),
    remove_elements(R1, T, R).
remove_elements(L, [], L).

% Retorna las palabras clave y la gramatica de un oracion
% Elimina los elementos repetidos de una gramatica
% Elimina elementos vacios de la lista
oracion(PalabrasClaveFinal, GramaticaFinal, Frase, []) :-
    phrase(oracion_auxiliar(PalabrasClave, Gramatica), Frase),
    list_to_set(Gramatica, GramaticaOrdenada),
    remove_elements(PalabrasClave, [[]], PalabrasClaveFinal),
    remove_elements(GramaticaOrdenada, [[]], GramaticaFinal).

% Se definen las tres posibles gramaticas para una oracion
oracion_auxiliar(PalabrasClave, Gramatica, Frase, []) :- sintagma_nominal(_, Numero, PalabrasClave1, Gramatica1, Frase1, []),
                                                sintagma_verbal(Numero, PalabrasClave2, Gramatica2, Frase2, []),
                                                concatenar(PalabrasClave1, PalabrasClave2, PalabrasClave),
                                                concatenar(Gramatica1, Gramatica2, Gramatica),
                                                concatenar(Frase1, Frase2, Frase);
                                                sintagma_nominal(_, _, PalabrasClave, Gramatica, Frase, []);
                                                sintagma_verbal(_, PalabrasClave, Gramatica, Frase, []).

% Sintagmas nominales y sus gramaticas
% Caso 1: "el origen"
% Caso 2: "mi origen"
% Caso 3: "Cartago"
% Caso 4: "yo"
sintagma_nominal(Genero, Numero, [PalabrasClave], [Gramatica]) --> determinante(Genero, Numero), nombre(Genero, Numero, PalabrasClave, Gramatica);
                                                                   determinante(impersonal, Numero), nombre(_Genero2, Numero, PalabrasClave, Gramatica);
                                                                   nombre(Genero, Numero, PalabrasClave, Gramatica).
sintagma_nominal(Genero, Numero, [[]], [[]]) --> determinante(Genero, Numero).

% Sintagmas verbales y sus gramaticas
% Caso 1: "no"
% Caso 2: "para Cartago"
% Caso 3: "es Cartago"
% Caso 4: "no voy para Cartago"
% Caso 5: "voy para Cartago"
sintagma_verbal(_, [PalabrasClave], [Gramatica]) --> modulizador(PalabrasClave, Gramatica).
sintagma_verbal(_, [PalabrasClave1, PalabrasClave2], [Gramatica1, Gramatica2]) -->
     enlace(PalabrasClave1, Gramatica1), sintagma_nominal(_, _, [PalabrasClave2], [Gramatica2]).
sintagma_verbal(Numero, [PalabrasClave1, PalabrasClave2], [Gramatica1, Gramatica2]) -->
    verbo_transitivo(Numero, PalabrasClave1, Gramatica1), sintagma_nominal(_, Numero, [PalabrasClave2], [Gramatica2]).
sintagma_verbal(Numero, [PalabrasClave1, PalabrasClave2, PalabrasClave3], [Gramatica1, Gramatica2, Gramatica3]) -->
    verbo_transitivo(Numero, PalabrasClave1, Gramatica1), enlace(PalabrasClave2, Gramatica2), sintagma_nominal(_, _, [PalabrasClave3], [Gramatica3]).
sintagma_verbal(Numero, [PalabrasClave1, PalabrasClave2, PalabrasClave3, PalabrasClave4], [Gramatica1, Gramatica2, Gramatica3, Gramatica4]) -->
    modulizador(PalabrasClave1, Gramatica1),
    verbo_transitivo(Numero, PalabrasClave2, Gramatica2),
    enlace(PalabrasClave3, Gramatica3),
    sintagma_nominal(_, _, [PalabrasClave4], [Gramatica4]).

% Determinantes
determinante(impersonal, singular) --> [mi].
determinante(masculino, singular) --> [el]; [un]; [yo]; [me].
determinante(femenino, singular) --> [una]; [la].

% Verbos
verbo_transitivo(singular, [], []) --> [es]; [se,ubica].
verbo_transitivo(singular, [ubico], [origen]) --> [ubico].
verbo_transitivo(singular, [voy], [destino]) --> [voy].
verbo_transitivo(singular, [encamino], [destino]) --> [encamino].
verbo_transitivo(singular, [dirijo], [destino]) --> [dirijo].
verbo_transitivo(singular, [estoy], [origen]) --> [estoy].
verbo_transitivo(singular, [encuentro], [origen]) --> [encuentro].
verbo_transitivo(singular, [ir], [destino]) --> [ir].

% Nombres
nombre(masculino, singular, [origen], [origen]) --> [origen].
nombre(masculino, singular, [punto, de, partida], [origen]) --> [punto, de, partida].
nombre(masculino, singular, [destino], [destino]) --> [destino].
nombre(masculino, singular, Lugar, Lugar, Lugar, _) :- phrase(lugar, Lugar).
nombre(Genero, Numero, Establecimiento, Establecimiento, Establecimiento, _) :- phrase(establecimiento(Genero, Numero), Establecimiento).
nombre(Genero, Numero, EstablecimientoNombre, EstablecimientoNombre, EstablecimientoNombre, _) :-
    phrase(establecimiento_nombre(Genero, Numero, _), EstablecimientoNombre).
nombre(masculino, singular, [punto, de, partida], [origen]) --> [punto, de, partida].
nombre(masculino, singular, [ubicacion], []) --> [ubicacion].

% Modulizadores
modulizador([si], [afirmacion]) --> [si].
modulizador([afirmativo], [afirmacion]) --> [afirmativo].
modulizador([claro], [afirmacion]) --> [claro].
modulizador([de, acuerdo], [afirmacion]) --> [de, acuerdo].
modulizador([por, supuesto], [afirmacion]) --> [por, supuesto].
modulizador([no], [negacion]) --> [no].
modulizador([negativo], [negacion]) --> [negativo].

% Enlaces
enlace([para], [destino]) --> [para].
enlace([hacia], [destino]) --> [hacia].
enlace([a], [destino]) --> [a].
enlace([al], [destino]) --> [al]. % Warning: [a] (enlace) + [el] (determinante)
enlace([en], [origen]) --> [en].

gramatica_valida(origen, Origen, [[origen], Origen], []) :- phrase(origen, Origen).
gramatica_valida(origen, Origen, [Origen], []) :- phrase(origen, Origen).

gramatica_valida(destino, Destino, [[destino], Destino], []) :- phrase(destino, Destino).
gramatica_valida(destino, Destino, [Destino], []) :- phrase(destino, Destino).

gramatica_valida(establecimiento, origen, Establecimiento, [[origen], Establecimiento], []) :- phrase(establecimiento(_,_), Establecimiento).
gramatica_valida(establecimiento, origen, Establecimiento, [Establecimiento], []) :- phrase(establecimiento(_,_), Establecimiento).

gramatica_valida(establecimiento, destino, Establecimiento, [[destino], Establecimiento], []) :- phrase(establecimiento(_,_), Establecimiento).
gramatica_valida(establecimiento, destino, Establecimiento, [Establecimiento], []) :- phrase(establecimiento(_,_), Establecimiento).

gramatica_valida(establecimiento_nombre(Tipo), _, EstablecimientoNombre, [EstablecimientoNombre], []) :-
    phrase(establecimiento_nombre(_,_,Tipo), EstablecimientoNombre).
gramatica_valida(establecimiento_nombre(Tipo), origen, EstablecimientoNombre, [[origen], EstablecimientoNombre], []) :-
    phrase(establecimiento_nombre(_,_,Tipo), EstablecimientoNombre).
gramatica_valida(establecimiento_nombre(Tipo), destino, EstablecimientoNombre, [[destino], EstablecimientoNombre], []) :-
    phrase(establecimiento_nombre(_,_,Tipo), EstablecimientoNombre).

gramatica_valida(confirmacion, [afirmacion], [[afirmacion]], []).
gramatica_valida(confirmacion, [negacion], [[negacion]], []).

% Se definen las preguntas (tipo de pregunta, pregunta).
pregunta(inicio,['Muchas',gracias,por,usar,'Wazelog','.',' ',la,mejor,forma,de,llegar,a,su,destino,'.']).
pregunta(origen,['¿','Dónde',se,encuentra,actualmente,'?']).
pregunta(establecimiento, origen, Establecimiento, Resultado) :- concatenar(['¿','En',cuál], Establecimiento, PrimeraParte),
                                                                 concatenar(PrimeraParte, [se,encuentra,'?'], Resultado).
pregunta(destino,['¿','Para',dónde,se,dirige,'?']).
pregunta(establecimiento, destino, Establecimiento, Resultado) :- concatenar(['¿','A',cuál], Establecimiento, PrimeraParte),
                                                                  concatenar(PrimeraParte, [desea,ir,'?'], Resultado).
pregunta(establecimiento_nombre, EstablecimientoNombre, Resultado) :- concatenar(['¿','Dónde',se,ubica], EstablecimientoNombre, PrimeraParte),
                                                                      concatenar(PrimeraParte, ['?'], Resultado).
pregunta(afirmacion1, ['¿','Desea',agregar,algún,destino,intermedio,'?']).
pregunta(afirmacion2, ['¿','Desea',agregar,otro,destino,intermedio,'?']).

% Se definen las respuestas (tipo de respuesta, oracion a responder, respuesta).
respuesta(origen, Oracion, Origen) :-
    phrase(oracion(_, Gramatica), Oracion), phrase(gramatica_valida(origen, Origen), Gramatica).
respuesta(establecimiento, Direccion, Oracion, Establecimiento) :-
    phrase(oracion(_,Gramatica), Oracion), phrase(gramatica_valida(establecimiento, Direccion, Establecimiento), Gramatica).
respuesta(destino, Oracion, Respuesta) :-
    phrase(oracion(_, Gramatica), Oracion), phrase(gramatica_valida(destino, Respuesta), Gramatica).
respuesta(establecimiento_nombre(Tipo), Direccion, Oracion, Establecimiento_Nombre) :-
    phrase(oracion(_,Gramatica), Oracion), phrase(gramatica_valida(establecimiento_nombre(Tipo), Direccion, Establecimiento_Nombre), Gramatica).
respuesta(confirmacion, Oracion, Confirmacion) :-
    phrase(oracion(_,Gramatica), Oracion), phrase(gramatica_valida(confirmacion, Confirmacion), Gramatica).

