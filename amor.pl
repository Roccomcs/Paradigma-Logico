/*
Cada persona se registra en nuestro sistema con un nombre, una edad, y un género con el que se identifica. 
Luego, se le pide algunos datos para identificar quiénes podrían ser sus pretendientes. En particular, debe 
especificar qué género o géneros le interesan, una edad mínima y máxima para sus parejas, y una cantidad 
ilimitada de cosas que le gustan y le disgustan. Una persona tiene su perfil incompleto si no proveyó alguno 
de estos datos, incluyendo gustos y disgustos, de los cuales deben completar con al menos cinco de cada uno. 
También se considera incompleto si su edad es menor a 18, ya que sólo admitimos mayores de edad.
*/

% persona(Nombre, Edad, Genero).
persona(tomas,20,masculino).
persona(martina,30,femenino).
persona(luca,60,alien).
persona(erika,20,femenino).
persona(sofia,50,femenino).

% Intereses por género (puede haber varios por persona)
interesGenero(tomas, femenino).
interesGenero(martina, masculino).
interesGenero(luca, femenino).
interesGenero(luca, masculino).
interesGenero(luca, alien).
interesGenero(erika, masculino).
interesGenero(erika, alien).
% sofia no tiene intereses de género

% Intereses por edad
interesEdad(tomas, 18, 30).
interesEdad(martina, 25, 35).
interesEdad(luca, 10, 60).
interesEdad(erika, 20, 60).
interesEdad(sofia, 90, 95).

% Gustos y disgustos
interesGustos(tomas, [deportes, musica, cine, viajar, leer], [desorden, ruido, conflictos, fumar, mentiras]).
interesGustos(martina, [], [fumar, alcohol, mentiras]).
interesGustos(luca, [cocina, cine, lectura, viajar, musica], [desorden, ruido, conflictos, mentiras, alcohol]).
interesGustos(erika, [juegos, deportes, musica, cine, lectura], [desorden, ruido, conflictos]).
interesGustos(sofia, [arte, musica, viajar, gastronomia, lectura], [fumar, alcohol, mentiras]).

perfilIncompleto(Nombre):-
    persona(Nombre,_,_),
    not(perfilCompleto(Nombre)).

%interesEdad e interesGenero devuelve true si existe al menos un hecho en esa posicion.
perfilCompleto(Nombre):-
    interesEdad(Nombre,_,_),
    interesGenero(Nombre,_),
    gustosDePerfil(Nombre),
    mayorDeEdad(Nombre).

gustosDePerfil(Nombre):-
    interesGustos(Nombre,Gustos,Disgustos),
    cincoOMas(Gustos),
    cincoOMas(Disgustos).

cincoOMas(Gustos):-
    length(Gustos,Cantidad),
    Cantidad >= 5.

mayorDeEdad(Nombre):-
    persona(Nombre,Edad,_),
    Edad >= 18.

/*
Sabiendo los perfiles de las personas, nuestros sistemas de análisis de datos empiezan a trabajar. 
Alguien es un alma libre si siente interés romántico por todos los géneros con los que se identifican 
los usuarios que están en nuestra base de conocimiento, o si acepta pretendientes en un rango más amplio 
que 30 años (por ejemplo: de 21 a 55, o de 40 a 72); mientras que quiere la herencia si la edad mínima 
que pretende para sus parejas es al menos 30 años más alta que su edad. También puede ocurrir que sea 
indeseable si no hay nadie que sea pretendiente de esa persona.
*/

almaLibre(Nombre):-
    persona(Nombre,_,_),
    forall(persona(_,_,Genero), interesGenero(Nombre,Genero)).

almaLibre(Nombre):-
    persona(Nombre,Edad,_),
    interesEdad(Nombre, EdadMinima, EdadMaxima),
    diferenciaDe30(EdadMaxima,EdadMinima).

diferenciaDe30(EdadMaxima,EdadMinima):-
    Diferencia is EdadMaxima - EdadMinima,
    Diferencia > 30.

quiereLaHerencia(Nombre):-
    persona(Nombre,Edad,_),
    interesEdad(Nombre,EdadMinima,_),
    EdadMinima - Edad >= 30.

noTienePretendientes(Persona):-
    persona(Persona,_,_),
    forall(persona(Pretendiente,_,_), not(esPretendienteDe(Pretendiente, Persona))).
    
/*
Con todos los perfiles en su lugar, es momento de matchear a las personas. Una persona es 
pretendiente de otra cuando el género y edad de la otra coinciden con los intereses de la 
primera, además de que ambas tienen al menos un gusto en común. Si dos personas son pretendientes 
entre sí, decimos que hay match. Esto genera algunas figuras geométricas interesantes: por ejemplo, 
tenemos un triángulo amoroso cuando una persona es pretendiente de otra, la cual es pretendiente 
de una tercera, la cual es pretendiente de la primera, pero sin matches entre ninguna de ellas. 
En otros casos, dos personas son el uno para el otro, porque además de haber match, no hay ningún 
gusto de una que le disguste a la otra.
*/    

esPretendienteDe(Pretendiente, Persona):-
    coincidenIntereses(Pretendiente,Persona),
    gustoEnComun(Pretendiente,Persona).

coincidenIntereses(Pretendiente,Persona):-
    persona(Pretendiente,_,_),
    persona(Persona,Edad,Genero),
    interesGenero(Pretendiente,Genero),
    persona(Persona,Edad,_),
    interesEdad(Pretendiente,EdadMinima,EdadMaxima),
    Edad >= EdadMinima,
    Edad =< EdadMaxima.

% Los member en este caso nos sirve para agarrar ambas listas y buscar un elemento en comun
gustoEnComun(Pretendiente,Persona):-
    interesGustos(Pretendiente,Gustos,_),
    interesGustos(Persona,OtrosGustos,_),
    member(Gusto,Gustos),
    member(Gusto,OtrosGustos).

hayMatch(Pretendiente,Persona):-
    esPretendienteDe(Pretendiente, Persona),
    esPretendienteDe(Persona, Pretendiente).

trianguloAmoroso(Pretendiente,Persona,Tercero):-
    leGustaSinMatch(Pretendiente,Persona),
    leGustaSinMatch(Persona,Tercero),
    leGustaSinMatch(Tercero,Pretendiente).

leGustaSinMatch(Pretendiente,Persona):-
    esPretendienteDe(Pretendiente, Persona),
    not(hayMatch(Pretendiente,Persona)).

sonElUnoParaOtro(Pretendiente,Persona):-
    persona(Pretendiente,_,_),  
    persona(Persona,_,_),
    hayMatch(Pretendiente,Persona),
    ningunGustoDisgusta(Pretendiente,Persona),
    ningunGustoDisgusta(Persona,Pretendiente).

% Los member en este caso nos sirve para agarrar ambas listas y buscar ningun elemento en comun    
ningunGustoDisgusta(Pretendiente,Persona):-
    interesGustos(Pretendiente,Gustos,Disgustos),
    interesGustos(Pretendiente,OtrosGustos,OtrosDisgustos),
    forall(member(Gustitos, Gustos), not(member(Gustitos, OtrosDisgustos))).

/*
Las personas pueden enviarse mensajes en el chat interno de nuestro sistema. Por una cuestión 
de privacidad, no podemos ver el contenido de los mensajes, pero sí tenemos el predicado indiceDeAmor/3, 
que relaciona a una persona que le envía un mensaje a otra con el índice de amor que tenía ese mensaje, 
el cual puede ir de 0 (en un mensaje como “hola”) a 10 (en un mensaje como “Te amo ❤️❤️❤️”). Por cada 
mensaje enviado se agrega una nueva cláusula de indiceDeAmor/3. Cuando para los mensajes entre dos personas 
ocurre que el índice de amor promedio de los mensajes enviados por una es más del doble respecto al índice 
de amor promedio de los mensajes enviados por la otra, decimos que hay un desbalance entre esas dos personas. 
Por último, una persona ghostea a la otra si recibió mensajes de ella pero jamás le respondió.
*/
    
% indiceDeAmor(Pretendiente,Persona,Indice)

indiceDeAmor(luca,erika,8).
indiceDeAmor(luca,erika,7).
indiceDeAmor(luca,erika,9).
indiceDeAmor(luca,erika,6).
indiceDeAmor(luca,erika,10).
indiceDeAmor(luca,erika,9).
indiceDeAmor(erika,luca,1).
indiceDeAmor(erika,luca,2).
indiceDeAmor(erika,luca,1).
indiceDeAmor(erika,luca,3).
indiceDeAmor(luca,tomas,2).

% Los primeros indiceDeAmor son para que sea inversible.
% Las listas \= [] es para que no se divida por cero.

desbalance(Pretendiente,Persona):-
    promedioDeIndiceDeAmor(Pretendiente,Persona,Indice1),
    promedioDeIndiceDeAmor(Persona,Pretendiente,Indice2),
    Indice1 > 2 * Indice2.

promedioDeIndiceDeAmor(Pretendiente,Persona,Promedio):-
    findall(Indice,indiceDeAmor(Pretendiente,Persona,Indice),Lista),
    sumlist(Lista, Suma),
    length(Lista, Cantidad),
    Promedio is Suma / Cantidad.


ghostea(Pretendiente,Ghosteado):-
    indiceDeAmor(Pretendiente,Ghosteado,_),
    not(indiceDeAmor(Ghosteado,Pretendiente,_)).
