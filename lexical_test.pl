/*
 * Ejemplo 6.2.6.
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
 */

camino --> [[cartago], [san,jose], 25];
           [[alajuela], [heredia], 7];
           [[san, jose], [alajuela], 15];
           [[cartago], [tres,rios], 10].

origen(S,_) :- camino([S|_],_).
destino(S,_) :- camino([_,S|_],_).

% Analogo a: oracion(A, B) :- sintagma_nominal(A,C), sintagma_verbal(C,B).
% Agregar caso: "Quiero ir a ..."
% Caso 1:
oracion --> sintagma_nominal(_Genero2, Numero), sintagma_verbal(Numero);
            sintagma_nominal(_Genero2, Numero);
            sintagma_verbal(Numero).

% Caso 1: "el origen / es ..."
% Caso 2: "mi origen / es ..."
% Caso 3: "Cartago"
% Caso 4: "yo / voy ..."
sintagma_nominal(Genero, Numero) --> determinante(Genero, Numero), nombre(Genero, Numero);
                                     determinante(impersonal, Numero), nombre(_Genero2, Numero);
                                     nombre(Genero, Numero);
                                     determinante(Genero, Numero).

% Caso 1: "no"
% Caso 2: "para Cartago"
% Caso 3: "no voy para Cartago"
% Caso 4: "voy PARA Cartago"
sintagma_verbal(Numero) --> modulizador;
                            enlace, sintagma_nominal(_Genero, _Numero2);
                            modulizador, verbo_transitivo(Numero), enlace, sintagma_nominal(_Genero, _Numero2);
                            verbo_transitivo(Numero), enlace, sintagma_nominal(_Genero, _Numero2).

% Sinonimos para verbos transitivos
sinonimo_verbo_transitivo(singular, ir) --> [quiero,ir].
sinonimo_verbo_transitivo(singular, voy) --> [dirijo].
sinonimo_verbo_transitivo(singular, estoy) --> [encuentro].

% Sinonimos de nombres
sinonimo_nombre(masculino, singular, origen) --> [punto,de,partida].
sinonimo_nombre(masculino, singular, parada) --> [punto,intermedio]; [destino,intermedio].

% Sinonimos de modulizadores
sinonimo_modulizador(si) --> [afirmativo]; [claro]; [de,acuerdo]; [por,supuesto].
sinonimo_modulizador(no) --> [negativo].

% Sinonimos de enlaces
sinonimo_enlace(para) --> [a].

% Determinantes
determinante(impersonal, singular) --> [mi].
determinante(masculino, singular) --> [el]; [un]; [yo]; [me].

% Verbos
verbo_transitivo(GeneroSinonimo) --> sinonimo_verbo_transitivo(GeneroSinonimo, _).
verbo_transitivo(singular) --> [es]; [voy]; [estoy]; [ir]; [se,ubica].

% Nombres
% Se manejaran casos con mayuscula desde Java.
nombre(GeneroSinonimo, NumeroSinonimo) --> sinonimo_nombre(GeneroSinonimo, NumeroSinonimo, _).
nombre(masculino, singular) --> [origen]; [destino].
nombre(masculino, singular) --> origen; destino.
nombre(femenino, singular) --> [parada].

% Modulizadores
modulizador --> sinonimo_modulizador(_).
modulizador --> [si]; [no].

% Enlaces
enlace --> sinonimo_enlace(_).
enlace --> [para]; [en].


/*
main :- writeln("Origen?"),
        busca_origen(Origen),
        write(Origen),
        write(" efectivamente es un origen.\n").


busca_origen(Origen) :- repeat,
                        read(Origen),
                        (origen([Origen],_) -> !; writeln("Error, el origen no existe, intente de nuevo."), fail).
*/

ejemplo(SSV) --> sintagma_nominal2(SSN), sintagma_verbal2(SSN,SSV).
sintagma_nominal2(SNP) --> nombre_propio(SNP).
sintagma_verbal2(X,SA) --> verbo_cop, atributo(X,SA).
atributo(X,SA) --> adjetivo(X,SA).
verbo_cop --> [es].
nombre_propio(juan) --> [juan].
nombre_propio(pedro) --> [pedro].
adjetivo(X,alto(X)) --> [alto].
adjetivo(X,bajo(X)) --> [bajo].

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






