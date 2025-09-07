% Recorridos en GBA:
%recorrido(Linea,Zona,Barrio)
recorrido(17, gba(sur), mitre).
recorrido(24, gba(sur), belgrano).
recorrido(247, gba(sur), onsari).
recorrido(60, gba(norte), maipu).
recorrido(152, gba(norte), olivos).

% Recorridos en CABA:
%recorrido(Linea,Zona,Calle)
recorrido(17, caba, santaFe).
recorrido(152, caba, santaFe).
recorrido(10, caba, santaFe).
recorrido(160, caba, medrano).
recorrido(24, caba, corrientes).

% 1. Saber si dos líneas pueden combinarse, que se cumple cuando su recorrido pasa por una misma calle dentro de la misma zona.
puedenCombinarse(Linea1,Linea2):-
    recorrido(Linea1,Zona,Calle),
    recorrido(Linea2,Zona,Calle),
    Linea1 \= Linea2. 

% 2. Conocer cuál es la jurisdicción de una línea, que puede ser o bien nacional, que se cumple cuando la misma cruza la General Paz,  
% o bien provincial, cuando no la cruza. Cuando la jurisdicción es provincial nos interesa conocer de qué provincia se trata, si es 
% de buenosAires (cualquier parte de GBA se considera de esta provincia) o si es de caba.
% Se considera que una línea cruza la General Paz cuando parte de su recorrido pasa por una calle de CABA y otra parte por una calle del 
% Gran Buenos Aires (sin importar de qué zona se trate). 

jurisdiccion(Linea,nacional):-
    cruzaGralPaz(Linea).

cruzaGralPaz(Linea):-
    recorrido(Linea,caba,_),
    recorrido(Linea,gba(_),_).

jurisdiccion(Linea,provincial(Provincia)):-
    recorrido(Linea,Zona,_),
    perteneceA(Zona,Provincia),
    not(cruzaGralPaz(Linea)).

perteneceA(caba, caba).
perteneceA(gba(_), buenosAires).

% 3. Saber cuál es la calle más transitada de una zona, que es por la que pasen mayor cantidad de líneas.

calleMasTransitada(Calle,Zona):-
    cuantasLineasPasan(Calle,Zona,Cantidad),
    forall(recorrido(_,Zona,OtraCalle), Calle \= OtraCalle), cuantasLineasPasan(OtraCalle,Zona,CantidadMenor), 
    Cantidad > CantidadMenor.

cuantasLineasPasan(Calle,Zona,Cantidad):-
    recorrido(_,Zona,Calle),
    findall(Calle,recorrido(_,Zona,Calle),ListaDeCalles),
    length(ListaDeCalles,Cantidad).
    
% 4. Saber cuáles son las calles de transbordos en una zona, que son aquellas por las que pasan al menos 3 líneas de colectivos, y todas son de jurisdicción nacional.

callesDeTransbordos(Calle,Zona):-
    recorrido(_,Zona,Calle),
    forall(recorrido(Linea,Zona,Calle),jurisdiccion(Linea,nacional)).
    cuantasLineasPasan(Calle,Zona,Cantidad),
    Cantidad >= 3,

% 5. Necesitamos incorporar a la base de conocimientos cuáles son los beneficios que las personas tienen asociadas a sus tarjetas registradas en el sistema SUBE. 
% Dichos beneficios pueden ser cualquiera de los siguientes:

% Estudiantil: el boleto tiene un costo fijo de $50.

% Personal de casas particulares: nos interesará registrar para este beneficio cuál es la zona en la que se encuentra el domicilio laboral. Si la línea que se 
% toma la persona con este beneficio pasa por dicha zona, se subsidia el valor total del boleto, por lo que no tiene costo.

% Jubilado: el boleto cuesta la mitad de su valor.

% Sabemos que:
% Pepito tiene el beneficio de personal de casas particulares dentro de la zona oeste del GBA.
% Juanita tiene el beneficio del boleto estudiantil.
% Tito no tiene ningún beneficio.
% Marta tiene beneficio de jubilada y también de personal de casas particulares dentro de CABA y en zona sur del GBA.

% A. Representar la información de los beneficios y beneficiarios.

%Nueva base de conocimientos
persona(pepito).
persona(juanita).
persona(tito).
persona(marta).

% beneficios existentes
% beneficio(TipoDeBeneficio,Linea,ValorNormal)
beneficio(estudiantil,_,50).

beneficio(personalCasaParticular(Zona),Linea,0):-
    recorrido(Linea,Zona,_).

beneficio(jubilado,Linea,ValorBonificado):-
    valorNormal(Linea,Valor),
    ValorBonificado is valor / 2.

% Quienes tienen esos beneficios
beneficiario(pepito, personalCasaParticular(gba(oeste))).
beneficiario(juanita, estudiantil).
beneficiario(marta, jubilado).
beneficiario(marta, personalCasaParticular(caba)).
beneficiario(marta, personalCasaParticular(gba(sur))).

% B. Saber, para una persona, cuánto le costaría viajar en una línea, considerando que:

% El valor normal del boleto (o sea, sin considerar beneficios) es de $500 si la línea es de jurisdicción nacional
valorNormal(Linea, 500):-
    jurisdiccion(Linea, nacional).

% De $350 si es provincial de CABA.
valorNormal(Linea, 350):-
    jurisdiccion(Linea, provincial(caba)).

% En caso de ser de jurisdicción de la provincia de Buenos Aires, cuesta $25 multiplicado por la cantidad de calles que 
% tiene en su recorrido más un plus de $50 si pasa por zonas diferentes de la provincia.

valorNormal(Linea, Valor):-
    jurisdiccion(Linea, provincial(buenosAires)),
    findall(Calle, recorrido(Linea, _, Calle), Calles),
    length(Calles, CantidadCalles),
    plus(Linea, Plus),
    Valor is (25*CantidadCalles) + Plus.

plus(Linea,50):-
    pasaPorDiferentesZonas(Linea).

plus(Linea,0):-
    not(pasaPorDiferentesZonas(Linea)).

pasaPorDiferentesZonas(Linea):-
    recorrido(Linea,gba(Zona),_),
    recorrido(Linea,gba(OtraZona),_),
    Zona \= OtraZona.


% C. Seria facil de implementar ya que habria que agregarlo en beneficio() y capaz hacer una funcion aparte si la necesitamos.