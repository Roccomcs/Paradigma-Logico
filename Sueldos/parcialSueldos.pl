/*
Punto 1: Por la plata baila el mono
Sabemos las personas que trabajan en un departamento. Por ejemplo en Ventas trabajan Kyle, Trisha y Joshua, mientras que Ian y Sherri trabajan en Logística.

También tenemos registrado cuánto gana cada persona:
si la persona es asalariada, sabemos cuántas horas trabaja
si la persona tiene gente a cargo, sabemos quiénes son las personas subordinadas, ordenadas por importancia
si la persona es independiente, sabemos cuál es el oficio que tiene

Por ejemplo:
Kyle es asalariado, trabaja 6 horas y gana 50
Sherri es asalariada, trabaja 7 horas y gana 60
Gus es asalariado, trabaja 8 horas y gana 60
Ian es jefe, tiene a su cargo a Kyle, Rob y Ginger, y gana 40
Trisha es jefa, tiene a su cargo a Ian y Gus y gana 90
Joshua es independiente, trabaja de arquitecto y gana 55
*/

%empleado(Nombre,Departamento,Tipo).
empleado(kyle,ventas,asalariado).
empleado(sherri,logistica,asalariado).
empleado(gus,_,asalariado).
empleado(ian,logistica,jefe).
empleado(trisha,ventas,jefe).
empleado(joshua,ventas,independiente).

%sueldo(Nombre,Horas,Ganancia).
sueldo(kyle,6,50).
sueldo(sherri,7,60).
sueldo(gus,8,60).
sueldo(ian,_,40).
sueldo(trisha,_,90).
sueldo(joshua,_,55).

%jefe(Nombre,Subordinados).
jefe(ian,[kyle,rob,ginger]).
jefe(trisha,[ian,gus]).

%independiente(Nombre,Trabajo).
independiente(joshua,arquitecto).

/*
Queremos saber si un departamento es paganini, eso ocurre si todas las personas que trabajan en él ganan bien.
un asalariado gana bien si gana más que el promedio en base a las horas trabajadas. Por ejemplo: el sueldo promedio de 6 horas es 45, el de 7 horas es 60 y el de 8 80.
un jefe gana bien si gana más de 20 * la cantidad de personas a cargo
y un independiente gana bien si es arquitecto o gana más de 70.
Ventas es un departamento paganini.
*/

esPaganini(Departamento):-
    empleado(_,Departamento,_),
    forall(empleado(Nombre,Departamento,_), ganaBien(Nombre)).

ganaBien(Nombre):-
    empleado(Nombre,_,asalariado),
    sueldo(Nombre,Horas,Ganancia),
    promedioHoras(Horas,Promedio),
    Ganancia > Promedio.

promedioHoras(6,45).
promedioHoras(7,60).
promedioHoras(8,80).

ganaBien(Nombre):-
    empleado(Nombre,_,jefe),
    sueldo(Nombre,_,Ganancia),
    jefe(Nombre,Subordinados),
    cantidadDeSubordinados(Subordinados,Cantidad),
    Ganancia > 20 * Cantidad.

cantidadDeSubordinados(Subordinado,Cantidad):-
    length(Subordinado,Cantidad).

ganaBien(Nombre):-
    empleado(Nombre,_,independiente),
    independiente(Nombre,arquitecto).

ganaBien(Nombre):-
    sueldo(Nombre,_,Ganancia),
    Ganancia > 70.

esPaganini(ventas).

/*
Sabemos en qué departamento le gusta trabajar a una persona.
A Kyle le gusta trabajar en Ventas o en Logística.
A Trisha y a Joshua le gusta trabajar en Ventas.
A Sherri le gusta trabajar en Contabilidad, pero también en Facturación y Cobranzas.

Queremos saber si un departamento está en problemas, esto ocurre si ninguna persona que trabaja en ese departamento quiere trabajar ahí. Logística es un departamento que está en problemas.
*/
    
estaEnProblemas(Departamento):-
    empleado(_,Departamento,_),
    forall(empleado(Nombre,Departamento,_), not(lesGusta(Departamento,Nombre))).

lesGusta(ventas,kyle).
lesGusta(logistica,kyle).
lesGusta(ventas,trisha).
lesGusta(ventas,joshua).
lesGusta(contabilidad,sherri).
lesGusta(facturacion,sherri).
lesGusta(cobranzas,sherri).

/*
Siempre es momento de reorganizaciones, queremos saber qué posiblilidades tenemos de rearmar un departamento en base a un presupuesto dado, donde queremos que por lo menos haya 2 personas. BONUS: que diga cuánta plata nos sobraría de ese presupuesto.

Personas sera una lista con nombres
member(Nombre,Personas) toma la lista de personas y le asigna un nombre a cada una, que luego se usara en empleado y sueldo
Tiene que estar dentro del findall para utilizar todos los elementos de la lista
*/

posibilidadDeRearmarV1(Personas,Presupuesto,Restante):-
    findall(Ganancia,(member(Nombre,Personas),empleado(Nombre,_,_),sueldo(Nombre,_,Ganancia)), ListaDeGanancias),
    sum_list(ListaDeGanancias, GananciaTotal),
    Restante is Presupuesto - GananciaTotal,
    Restante >= 0.