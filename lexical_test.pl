/*
 * Ejemplo 6.2.5.
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
 */

camino('Cartago', "San Jose", 15).

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
                            verbo_transitivo(Numero), sintagma_nominal(_Genero, _Numero2);
                            modulizador, verbo_transitivo(Numero), enlace, sintagma_nominal(_Genero, _Numero2);
                            verbo_transitivo(Numero), enlace, sintagma_nominal(_Genero, _Numero2).

% Sinonimos de nombres
sinonimo(origen, "punto de partida").

% Sinonimos de modulizadores
sinonimo(si, sí).
sinonimo(si, afirmativo).
sinonimo(si, claro).
sinonimo(si, "de acuerdo").
sinonimo(si, "por supuesto").
sinonimo(no, negativo).

% Sinonimos de enlaces
sinonimo(para, a).

% Determinantes
determinante(impersonal, singular) --> [mi].
determinante(masculino, singular) --> [el]; [un]; [yo]; [me].

% Verbos
verbo_transitivo(singular) --> [es]; [voy]; [dirijo]; [estoy].

% Nombres
% Se manejaran casos como "WazeLog" o "Wazelog" con string_lower("WazeLog",X).
nombre(masculino, singular) --> [origen]; [destino]; [parada]; [wazelog].
nombre(masculino, singular, [S|_], _) :- sinonimo(origen, S).
nombre(masculino, singular, [X|_], _) :- camino(X, _Lugar2, _Peso).
nombre(masculino, singular, [Y|_], _) :- camino(_Lugar1, Y, _Peso).

modulizador --> [si]; [no].
modulizador([S|_], _) :- sinonimo(si, S).

enlace --> [para]; [en].
enlace([S|_], _) :- sinonimo(para, S).

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






