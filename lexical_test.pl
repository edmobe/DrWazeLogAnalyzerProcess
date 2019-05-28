/*
 * Ejemplo 6.2.9.
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
 */

% Base de datos
camino --> [[cartago], [san, jose], 25];
           [[alajuela], [heredia], 7];
           [[san, jose], [alajuela], 15];
           [[cartago], [tres, rios], 10].

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

validar(Categoria, Frase) :- phrase(oracion(_, Gramatica), Frase),
                             phrase(gramatica_valida(Categoria), Gramatica).

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
nombre(masculino, singular, Lugar, [lugar], Lugar, _) :- phrase(lugar, Lugar).
nombre(femenino, singular, [parada], [parada]) --> [parada].
nombre(masculino, singular, [punto, de, partida], [origen]) --> [punto, de, partida].

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
enlace([en], [origen]) --> [en].

% Falta quitar elementos vacios de una lista
% Falta quitar elementos repetidos de una lista
% Falta validar gramaticas e interpretarlas
% Falta hacer conversacion

gramatica_valida(origen) --> [[origen], [lugar]];
                             [[lugar], [origen]].
gramatica_valida(destino) --> [[destino], [lugar]];
                              [[lugar], [destino]].
gramatica_valida(parada) --> [[parada], [lugar]];
                             [[lugar], [parada]].
gramatica_valida(confirmacion) --> [afirmacion];
                                   [negacion].



/*
main :- writeln("Origen?"),
        validar(origen),
        write(" efectivamente es un origen.\n").

preguntar(origen) :- writeln("Cual es el origen del viaje?\n").

validar(Objetivo) :- repeat,
                     read(Oracion),
                     (phrase(oracion, Oracion) ->
                           autollenar(Objetivo, Oracion, Autollenado),
                           (phrase(gramatica_palabras_clave(Oracion), Gramatica1), phrase(gramatica_palabras_clave(Autollenado), Gramatica2)),
                           ((phrase(gramatica_valida(Objetivo), Gramatica1); phrase(gramatica_valida(Objetivo), Gramatica2)) ->
                                true;
                                write("Comprendo lo que dices pero no puedo responderte con esa informacion. "), preguntar(Objetivo), fail);
                           writeln("No te entiendo. "), preguntar(Objetivo), fail).

*/

/*
 * - Origen: Hola WazeLog estoy en Cartago
 * - Destino: San Jose
 * - Destino intermedio: Tengo que pasar al supermercado
 * - ¿Cuál supermercado?: Me gustaria Automercado
 * - ¿Dónde se encuentra ese supermercado?: Tres Rios
 * - Destino intermedio: No
 * -
*/

/*Issues:
"Voy para X", "Mi destino es X", "Me dirijo a X"
"Estoy en Y", "Me encuentro en Y", "Parto de Y", "Mi origen es Y", "El origen del viaje es Y"
*/






