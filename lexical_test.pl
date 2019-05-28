/*
 * Ejemplo 6.2.8.
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
 */

concatenar([], L, L).
concatenar([X|L1], L2, [X|L3]) :- concatenar(L1, L2, L3).

camino --> [[cartago], [san, jose], 25];
           [[alajuela], [heredia], 7];
           [[san, jose], [alajuela], 15];
           [[cartago], [tres, rios], 10].

origen(S,_) :- camino([S|_],_).
destino(S,_) :- camino([_,S|_],_).

lugar --> origen; destino.

% El problema es que no se pueden concatenar listas como lo estoy haciendo
% Analogo a: oracion(A, B) :- sintagma_nominal(A,C), sintagma_verbal(C,B).
oracion(PalabrasClave, Frase, []) :- sintagma_nominal(_, Numero, PalabrasClave1, Frase1, []),
                                      sintagma_verbal(Numero, PalabrasClave2, Frase2, []),
                                      concatenar(PalabrasClave1, PalabrasClave2, PalabrasClave),
                                      concatenar(Frase1, Frase2, Frase);
                                      sintagma_nominal(_, _, PalabrasClave, Frase, []);
                                      sintagma_verbal(_, PalabrasClave, Frase, []).

/*
oracion([PalabrasClave1, PalabrasClave2]) --> sintagma_nominal(_, Numero, PalabrasClave1), sintagma_verbal(Numero, PalabrasClave2).
oracion([PalabrasClave]) --> sintagma_nominal(_, _, PalabrasClave).
oracion([PalabrasClave]) --> sintagma_verbal(_, PalabrasClave).
*/

% Caso 1: "el origen / es ..."
% Caso 2: "mi origen / es ..."
% Caso 3: "Cartago"
% Caso 4: "yo / voy ..."
sintagma_nominal(Genero, Numero, [PalabrasClave]) --> determinante(Genero, Numero), nombre(Genero, Numero, PalabrasClave);
                                                      determinante(impersonal, Numero), nombre(_Genero2, Numero, PalabrasClave);
                                                      nombre(Genero, Numero, PalabrasClave).
sintagma_nominal(Genero, Numero, [[]]) --> determinante(Genero, Numero).

% Caso 1: "no"
% Caso 2: "para Cartago"
% Caso 3: "es Cartago"
% Caso 4: "no voy para Cartago"
% Caso 5: "voy PARA Cartago"
sintagma_verbal(_, [PalabrasClave]) --> modulizador(PalabrasClave).
sintagma_verbal(_, [PalabrasClave1, PalabrasClave2]) --> enlace(PalabrasClave1), sintagma_nominal(_, _, [PalabrasClave2]).
sintagma_verbal(Numero, [PalabrasClave1, PalabrasClave2]) -->
    verbo_transitivo(Numero, PalabrasClave1), sintagma_nominal(_, Numero, [PalabrasClave2]).
sintagma_verbal(Numero, [PalabrasClave1, PalabrasClave2, PalabrasClave3]) -->
    verbo_transitivo(Numero, PalabrasClave1), enlace(PalabrasClave2), sintagma_nominal(_, _, [PalabrasClave3]).
sintagma_verbal(Numero, [PalabrasClave1, PalabrasClave2, PalabrasClave3, PalabrasClave4]) -->
    modulizador(PalabrasClave1), verbo_transitivo(Numero, PalabrasClave2), enlace(PalabrasClave3), sintagma_nominal(_, _, [PalabrasClave4]).

% Determinantes
determinante(impersonal, singular) --> [mi].
determinante(masculino, singular) --> [el]; [un]; [yo]; [me].
determinante(femenino, singular) --> [una]; [la].

% Verbos
% verbo_transitivo(GeneroSinonimo) --> sinonimo_verbo_transitivo(GeneroSinonimo, _).
% FALTAN SINONIMOS
verbo_transitivo(singular, []) --> [es]; [se,ubica].
verbo_transitivo(singular, [ubico]) --> [ubico].
verbo_transitivo(singular, [voy]) --> [voy].
verbo_transitivo(singular, [estoy]) --> [estoy].
verbo_transitivo(singular, [ir]) --> [ir].

% Nombres
% Se manejaran casos con mayuscula desde Java.
% FALTAN SINONIMOS
nombre(masculino, singular, [origen]) --> [origen].
nombre(masculino, singular, [destino]) --> [destino].
nombre(masculino, singular, Lugar, Lugar, _) :- phrase(lugar, Lugar).
nombre(femenino, singular, [parada]) --> [parada].

% Modulizadores
% modulizador --> sinonimo_modulizador(_).
% FALTAN SINONIMOS
modulizador([si]) --> [si].
modulizador([no]) --> [no].

% Enlaces
% enlace --> sinonimo_enlace(_).
% FALTAN SINONIMOS
enlace([para]) --> [para].
enlace([en]) --> [en].

/*
% palabra --> lugar; determinante(_, _); verbo_transitivo(_); nombre(_,
% _); modulizador; enlace.

% Sinonimos para verbos transitivos
sinonimo(verbo_transitivo, singular, ir) --> [quiero,ir].
sinonimo(verbo_transitivo, singular, voy) --> [dirijo].
sinonimo(verbo_transitivo, singular, estoy) --> [encuentro].

% Sinonimos de nombres
sinonimo(nombre, masculino, singular, origen) --> [punto,de,partida].
sinonimo(nombre, masculino, singular, parada) --> [punto,intermedio]; [destino,intermedio].

% Sinonimos de modulizadores
sinonimo(modulizador, si) --> [afirmativo]; [claro]; [de,acuerdo]; [por,supuesto].
sinonimo(modulizador, no) --> [negativo].

% Sinonimos de enlaces
sinonimo(enlace, para) --> [a].


% Palabras clave, significado
palabra_clave([origen], origen).
palabra_clave([destino], destino).
palabra_clave([parada], parada).
palabra_clave([a], destino).
palabra_clave([voy], destino).
palabra_clave([estoy], origen).
palabra_clave([ir], destino).
palabra_clave([ubico], origen).
palabra_clave([si], afirmacion).
palabra_clave([no], negacion).
palabra_clave([para], destino).
palabra_clave(Lugar, lugar_origen) :- origen(Lugar, []).
palabra_clave(Lugar, lugar_destino) :- destino(Lugar, []).
palabra_clave(Lugar, lugar_parada) :- origen(Lugar, []), destino(Lugar, []).
%faltan sinonimos!!!!!!!!

gramatica_valida(origen) --> [origen], [lugar_origen];
                             [lugar_origen], [origen].
gramatica_valida(destino) --> [destino], [lugar_destino];
                              [lugar_destino], [destino].
gramatica_valida(parada) --> [parada], [lugar_parada];
                             [lugar_parada], [parada].
gramatica_valida(confirmacion) --> [afirmacion];
                                   [negacion].
/*
extraer_palabras_clave(L, LE) :- extraer_palabras_clave(L, [], LE).
extraer_palabras_clave([], LE, LE).
extraer_palabras_clave([X,Y|L1], L2, L3) :- (palabra([X], _) -> (palabra_clave([X], _) -> extraer_palabras_clave([Y|L1], [X|L2], L3); extraer_palabras_clave([Y|L1], L2, L3)); extraer_palabras_clave([[X,Y]], L2, L3)).
*/

categorizar_palabras_clave(L, LC) :- categorizar_palabras_clave(L, [], LC).
categorizar_palabras_clave([], LC, LC).
categorizar_palabras_clave([X|L1], L2, L3) :- (palabra_clave([X], T) -> categorizar_palabras_clave(L1, [T|L2], L3); categorizar_palabras_clave(L1, L2, L3)).

gramatica_palabras_clave(L, G, []) :- categorizar_palabras_clave(L, L1), sort(L1, G).

autollenar(origen, Oracion, Resultado) :- concatenar([estoy, en], Oracion, Resultado).

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






