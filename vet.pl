%   PARA INICIAR ESCRIBA inicio.

%   declaracion de librerias para utilizar interfaz gráfica
:-use_module(library(pce)).
:-use_module(library(pce_style_item)).

%   Iniciar la interfaz grafica.
%   Botones, labels, y su posición dentro del dialog en pantalla.
inicio:-
%   Declaración
	new(Menu, dialog('Diagnostico Veterinario (Main Menu)', size(1000,1000))),
	new(L,label(nombre,'DV-UMG-LJRP v1.00.09')),
	new(@texto,label(nombre,'Realiza un nuevo diagnóstico para continuar')),
	new(@boton,button('realizar diagnóstico',message(@prolog,botones))),
	new(A,label(nombre,'Luis José Ruano Pérez 2692-12-4853')),
	new(Salir,button('SALIR',and(message(Menu, destroy),message(Menu,free)))),
	new(@respl,label(nombre,'')),

%   Posicionamiento
%   Se posicionaron dos elementos en x a 350 ya que el dialog no valida el size establecido, entonces esto alarga la ventana.
	send(Menu,append(L)),new(@btncarrera,button('¿Diagnostico?')),
	send(Menu,display,L,point(350,20)),
	send(Menu,display,A,point(40,360)),
	send(Menu,display,@texto,point(20,100)),
	send(Menu,display,@boton,point(85,150)),
	send(Menu,display,Salir,point(350,400)),
	send(Menu,display,@respl,point(20,130)),
	send(Menu,open).

%   Tratamientos segun la enfermedad del animal de acuerdo a los resultados del diagnóstico

fallas('Otitis:
    Como en todas las diarreas, en el tratamiento de la infección
    por Campylobacter resulta fundamental asegurar una adecuada
    hidratación durante la fase aguda de la enfermedad, siendo necesaria la reposición
    de líquidos y electrolitos para compensar las pérdidas sufridas.
    Y dieta solida en pequeñas porciones.'):-otitis,!.

fallas('Moquillo:
    Una enfermedad que, afortunadamente, tiene vacuna para prevenirla,
    pero que es sumamente contagiosa y llega a ser mortal en los animales no
    inoculados o de pocas semanas de vida.
    El moquillo en ocasiones no se puede diagnosticar, por eso es conocido
    como ‘la patología de los mil síntomas’: tos, estornudos, secreciones,
    fiebre, diarrea y tics nerviosos son solo algunos de ellos.'):-moquillo,!.

fallas('Sarna:
    Se trata de una enfermedad de la piel que también puede aparecer en los gatos
    y hasta en las personas. La sarna está causada por unos parásitos microscópicos llamados ácaros
    que perforan la dermis y la infectan. Hay dos tipos de sarna más frecuentes en perros:
    sarcóptica –se contagia al contacto con un animal infectado– y demodécica.
     Esta última está relacionada a problemas inmunitarios o genéticos.'):-sarna,!.

fallas('Artrosis:
    Esta es una de las enfermedades frecuentes en perros ancianos y de ciertas razas como el
    pastor alemán o el dóberman. La artrosis es la inflamación y degeneración de las articulaciones,
    principalmente de la cadera y el codo.
    El riesgo de padecer este problema aumenta si el animal es obeso o no hace demasiado ejercicio físico.'):-artrosis,!.

fallas('Enfermedad desconocida').

% Preguntas para tratar las posibles enfermedades.
    %   Serie de preguntas
otitis:- oido_infectado,
	pregunta('¿Su mascota se rasca mucho las orejas?'),
	pregunta('¿Su mascota mueve la cabeza constantemente hacia los laterales?'),
	pregunta('¿Su mascota sus cavidades auditivas desprenden mal holor?'),
	pregunta('¿Su mascota segrega un líquido amarillo de los oidos? ').

moquillo:- moquillo_mortal,
	pregunta('¿Su mascota tiene tos?'),
	pregunta('¿Su mascota estornuda constantemente?'),
	pregunta('¿Su mascota secreciones en la nariz? '),
	pregunta('¿Su mascota presenta fiebre y diarrea? '),
	pregunta('¿Su mascota presenta tics nerviosos?').

sarna:- piel_infectada,
	pregunta('¿Su mascota se rasca constantemente?'),
	pregunta('¿Su mascota presenta enrojecimiento en la piel?'),
	pregunta('¿Su mascota se rasca contra objetos y el suelo en busca de alivio?'),
	pregunta('¿Su mascota ha perdido peso?').

artrosis:- articulaciones_deformadas,
	pregunta('¿Su mascota tiene dificultada para subir superficies?'),
	pregunta('Su mascota presenta perdida de masa muscular?'),
	pregunta('¿Su mascota presenta falta de apetito por malestar? ').

%identificador de enfermedad que dirige a las preguntas correspondientes

oido_infectado:-pregunta('¿Su mascota se rasca mucho las orejas?'),!.
moquillo_mortal:-pregunta('¿Su mascota tiene tos?'),!.
piel_infectada:-pregunta('¿Su mascota se rasca constantemente?'),!.
articulaciones_deformadas:-pregunta('¿Su mascota tiene dificultada para subir superficies?'),!.

% Proceso del diagnostico basado en preguntas de SI/NO.
% Cuando el usuario dice SI, el parámetro que recibe es la siguiente pregunta de la misma enfermedad.
% Cuando dice NO, cambia a la primera pregunta de otra rama para evaluar la continuidad.

:-dynamic si/1, no/1.
preguntar(Problema):- new(Di,dialog('Diagnostico Veterinario AV-UMG-LJRP')),
     new(L2,label(texto,'Responde las siguientes preguntas')),
     new(La,label(prob,Problema)),
     new(B1,button(si,and(message(Di,return,si)))),
     new(B2,button(no,and(message(Di,return,no)))),

     send(Di,append(L2)),
	 send(Di,append(La)),
	 send(Di,append(B1)),
	 send(Di,append(B2)),

	 send(Di,default_button,si),
	 send(Di,open),get(Di,confirm,Answer),
	 write(Answer),send(Di,destroy),
	 ((Answer==si)->assert(si(Problema));
	 assert(no(Problema)),fail).

% cada vez que se conteste una pregunta la pantalla se limpia para
% volver a preguntar

pregunta(S):-(si(S)->true; (no(S)->false; preguntar(S))).
limpiar :- retract(si(_)),fail.
limpiar :- retract(no(_)),fail.
limpiar.

% proceso de eleccion de acuerdo al diagnostico basado en las preguntas
% anteriores

botones :- lim,
	send(@boton,free),
	send(@btncarrera,free),
	fallas(Falla),
	send(@texto,selection('Diagnóstico finalizado, resultado: ')),
	send(@respl,selection(Falla)),
	new(@boton,button('inicia procedimiento diagnostico',message(@prolog,botones))),
        send(Menu,display,@boton,point(40,50)),
        send(Menu,display,@btncarrera,point(20,50)),
limpiar.
lim :- send(@respl, selection('')).
