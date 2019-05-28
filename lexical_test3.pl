/*
 * Ejemplo 6.2.3.
 * Se busca simplificar la notacion de las gramaticas libres de contexto
 * Segun lo investigado, hay otra manera de expresar las gramaticas
 * Fuente: https://www.cs.us.es/cursos/ia2-2004/temas/tema-03.pdf
 * Fuente: https://personal.us.es/fsoler/papers/05capgram.pdf
*/

camino('Cartago',"San Jose",15).

% Se agrega el caso del sujeto omitido para casos como "Quiero ir a ..."
% Se agrega el caso del predicado omitido para casos como "Cartago"
oracion --> sintagma_nominal(_Genero2, Numero), sintagma_verbal(Numero);
sintagma_nominal(_Genero2,Numero);
sintagma_verbal(Numero).


% Se agrega el caso de impersonal para casos como "mi origen es ..."
% Se agrega el caso de determinante omitido para casos como "Cartago"
sintagma_nominal(Genero,Numero) --> determinante(Genero,Numero), nombre(Genero,Numero);
determinante(impersonal,Numero), nombre(_Genero2,Numero);
nombre(Genero,Numero).

% Se agrega el caso de solamente el modulizador para casos como "no"
% Se agregan un caso de enlace para casos como "voy PARA Cartago"
% Se agregan un caso de enlace para casos como "PARA Cartago"
sintagma_verbal(Numero) --> modulizador;
modulizador, verbo_transitivo(Numero), sintagma_nominal(_Genero,_Numero2);
verbo_transitivo(Numero),sintagma_nominal(_Genero,_Numero2);
modulizador, verbo_transitivo(Numero), enlace, sintagma_nominal(_Genero,_Numero2);
verbo_transitivo(Numero),sintagma_nominal(_Genero,_Numero2).

determinante(impersonal,singular) --> [mi].
determinante(masculino,singular) --> [el];[un].

verbo_transitivo(singular) --> [es].

nombre(masculino,singular) --> [origen];[destino];["punto de partida"];[parada];['WazeLog'];['Wazelog'];[wazelog];['Cartago'].

modulizador --> [sí];[si];[no].

enlace --> [para];[en].

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
