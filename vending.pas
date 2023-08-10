PROGRAM maquinaexpendedora;
CONST
 LONGCODIGO = 4; {longitud del codigo de usuario}
 LONGFECHA = 10; {longitud de la fecha}
 MAXUSUARIOS = 100; {numero maximo de usuarios}
 MAXPRODUCTOS = 50; {numero maximo de productos}
 MAXVENTAS = 120; {numero maximo de ventas}

TYPE
	tCodigoTarjeta = string[LONGCODIGO];
	tFecha = string[LONGFECHA];
{tipo usuario}
	tUsuario = RECORD
		nombre: string;
		codigoTarjeta: tCodigoTarjeta;
		saldo: real;
		END;
{tipo producto}
	tProducto = RECORD
		nombre, marca: string;
		precio: real;
		stock: integer;
		END;
{tipo venta}
	tVenta = RECORD
		nombreProducto: string;
		codigoTarjeta: tCodigoTarjeta;
		fecha : tFecha;
		END;


{tipo lista de usuarios}
	tIndiceUsuarios = 1..MAXUSUARIOS;
	tListaUsuarios = ARRAY [tIndiceUsuarios] OF tUsuario;

{Array parcialmente lleno para usuarios}
	tUsuarios = RECORD
		usuarios: tListaUsuarios;
		tope: integer;
		END;
{tipo lista de productos}
	tIndiceProductos = 1..MAXPRODUCTOS;
	tListaProductos = ARRAY [tIndiceProductos] OF tProducto;

{Array parcialmente lleno para productos}
	tProductos = RECORD
		productos: tListaProductos;
		tope: integer;
		END;

{tipo lista de ventas}
	tIndiceVentas = 1..MAXVENTAS;
	tListaVentas= ARRAY [tIndiceVentas] OF tVenta;

{Array parcialmente lleno para ventas}
	tVentas = RECORD
		ventas: tListaVentas;
		tope: integer;
		END;
{tipo archivos binarios}
	tArchivoUsuarios = FILE OF tUsuario;
	tArchivoProductos = FILE OF tProducto;
	tArchivoVentas = FILE OF tVenta;

PROCEDURE leerProductos(VAR ficheroProductos1:tArchivoProductos; VAR listado1:tProductos);
VAR
	i,j:integer;
BEGIN
	i:=0;
	assign(ficheroProductos1,'C:\fichero\productos.dat');
    {$I-}
	reset(ficheroProductos1);
	{$I+}
	IF (IOResult=0) THEN
	BEGIN
		REPEAT
			BEGIN
				i:=i+1;
				read(ficheroProductos1,listado1.productos[i]);
			END;
		UNTIL EOF(ficheroProductos1);
		close(ficheroProductos1);
		listado1.tope:=i+1;
	END
	ELSE writeln('No existe el archivo binario');
END;{FIN de leerProductos}

PROCEDURE leerUsuarios(VAR ficheroUsuario1:tArchivoUsuarios; VAR enumerado1:tUsuarios);
VAR
	i,j:integer;
BEGIN
	i:=0;
	assign(ficheroUsuario1,'C:\fichero\usuarios.dat');
    {$I-}
	reset(ficheroUsuario1);
	{$I+}
	IF (IOResult=0) THEN
	BEGIN
		REPEAT
			BEGIN
				i:=i+1;
				read(ficheroUsuario1,enumerado1.usuarios[i]);

			END;
		UNTIL EOF(ficheroUsuario1);
		close(ficheroUsuario1);
		enumerado1.tope:=i+1;
	END
	ELSE writeln('No existe el fichero binario.');
END;{FIN de leerUsuarios}

PROCEDURE leerVentas(VAR ficheroVentas1:tArchivoVentas; VAR listadoVentas1:tVentas);
VAR
	i:integer;
BEGIN
	i:=0;
	assign(ficheroVentas1,'C:\fichero\ventas.dat');
    {$I-}
	reset(ficheroVentas1);
	{$I+}
	IF (IOResult=0) THEN BEGIN
		REPEAT
			BEGIN
				i:=i+1;
				read(ficheroVentas1,listadoVentas1.ventas[i]);

			END;
		UNTIL EOF(ficheroVentas1);
		close(ficheroVentas1);
		listadoVentas1.tope:=i;
		END
	ELSE writeln('No existe el fichero binario.');
END;{FIN de leerVentas}

PROCEDURE MenuReponedor;
BEGIN
	writeln;
	writeln('* MENU REPONEDOR *');
	writeln('a) Venta de tarjeta');
	writeln('b) Baja tarjeta');
	writeln('c) Agregar producto');
	writeln('d) Eliminar producto');
	writeln('e) Listado productos');
	writeln('f) Listado usuarios');
	writeln('g) Listado ventas');
	writeln('h) Listado de usuarios que no han comprado');
	writeln('i) Listado de productos que han sido vendidos');
	writeln('j) Hacer backup');
	writeln('k) Restaurar backup');
	writeln('l) Guardar ventas');
	writeln('m) Salir');
END;{FIN de MenuReponedor}

PROCEDURE MenuComprador;
BEGIN
	writeln('Que deseas?');
	writeln('a) Compra de producto');
	writeln('b) Meter dinero en la tarjeta');
	writeln('c) Salir');
END;{FIN de MenuComprador}

FUNCTION LeerProducto(listado1:tProductos; nombre1:string):integer;
VAR
	i:integer;
BEGIN
	i:=0;
	REPEAT
		i:= i+1;
	UNTIL (i=listado1.tope) OR (nombre1=listado1.productos[i].nombre);
	IF (nombre1=listado1.productos[i].nombre) THEN
		LeerProducto:=0
	ELSE
		LeerProducto:=1;
END;{FIN de LeerProducto}

PROCEDURE InsertarProducto(VAR listado1:tProductos; producto1:tProducto);
VAR
	i,j:integer;
	nuevostock:integer;
BEGIN
	WITH listado1 DO
		IF tope < MAXPRODUCTOS THEN {A partir de este IF registramos el producto}
		BEGIN {Hay sitio en el listado}
			i:=0;
			REPEAT
				i:= i+1;
			UNTIL (i=tope) OR (producto1.nombre=productos[i].nombre);
			IF (producto1.nombre=productos[i].nombre) THEN{Esta repetido}
				BEGIN
				writeln('Producto ya registrado.Introduce el nuevo stock:');
				readln(nuevostock);
				WHILE nuevostock<=0 DO
					BEGIN
					writeln('Ingresa un stock mayor que 0');
					readln(nuevostock);
					END;{WHILE}
				productos[i].stock:=nuevostock;
				writeln('Stock actualizado');
				END{IF}
			ELSE
			BEGIN
				tope := tope + 1;
				productos[i] := producto1;
				writeln('El producto se ha agregado correctamente');
			END;{ELSE}
		END{IF}
		ELSE
			writeln('El listado esta lleno, no se puede agregar');
END;{FIN de InsertarProducto}

PROCEDURE escribirProductos (objetos1:tProducto);
BEGIN
	WITH objetos1 DO BEGIN
		writeln('-------------------------------------------------------------------------------------------');
		writeln('Nombre: ',nombre,'  Marca: ',marca,'  Precio: ',precio:2:2,' euros  Stock: ',stock,' uds.');

	END;
END;{FIN de escribirProductos}

PROCEDURE listadoProductos(listado1:tProductos);
VAR
	i,j:integer;
	temporal:tProducto;
BEGIN
	WITH listado1 DO BEGIN
		IF tope=0 THEN
			writeln('El listado se encuentra vacio.')
		ELSE BEGIN
		  FOR i := tope-1 DOWNTO 2 DO
	        FOR j := 0 TO i - 1 DO
	            IF productos[j].nombre >productos[j+1].nombre THEN
	            BEGIN
	                temporal :=productos[j];
	                productos[j] :=productos[j + 1];
	                productos[j + 1]:= temporal;
	            END;

	    		FOR i:=1 TO tope-1 DO
					escribirProductos(productos[i]);
	    END;
	END;
END;{FIN de listadoProductos}

PROCEDURE escribirUsuarios(usuario1:tUsuario);
BEGIN
	WITH usuario1 DO
		writeln('-Nombre: ',nombre,' |  Codigo: ',Codigotarjeta,' |  Saldo: ',saldo:2:2,' euros');
END;{FIN de escribirUsuarios}

PROCEDURE listadoUsuarios(enumerado1:tUsuarios);
VAR
	i:integer;
BEGIN
	WITH enumerado1 DO BEGIN
		IF tope=0 THEN
			writeln('El listado se encuentra vacio.')
		ELSE BEGIN
		  FOR i:=1 TO tope-1 DO
			escribirUsuarios(usuarios[i]);
	    END;
	END;
END;{FIN de listadoUsuarios}

FUNCTION buscaNombre(listado1: tProductos; nom:string):integer;
VAR
    encontrado,i: integer;
BEGIN
    encontrado := 0;
    i := 1;
	WHILE (encontrado = 0) AND (i <= listado1.tope-1) DO
		BEGIN
			IF (listado1.productos[i].nombre = nom)THEN
				encontrado := i
			ELSE
			i:= i + 1;
		END;
	buscaNombre:= encontrado;
END;{FIN de buscaNombre}

PROCEDURE eliminarProducto (VAR listado1:tProductos; nombre1:string);
VAR
	i,j,stop:integer;
BEGIN {eliminar Producto}
	stop:=listado1.tope-1;
	WITH listado1 DO BEGIN
		IF stop=0 THEN
			writeln('El listado esta vacio')
		ELSE BEGIN
			FOR j:=i TO stop-1 DO
			productos[j]:=productos[j+1];
			tope := tope - 1;
			writeln('El producto ha sido eliminado');
		END

    END;{with}
END;{FIN de eliminarProducto}

FUNCTION buscaCodigo(enumerado1: tUsuarios; codigo1:string):integer;
VAR
    encontrado,i: integer;
BEGIN
    encontrado := 0;
    i := 1;
	WHILE (encontrado = 0) AND (i <= enumerado1.tope-1) DO
		BEGIN
			IF (enumerado1.usuarios[i].codigoTarjeta = codigo1)THEN
				encontrado := i
			ELSE
			i:= i + 1;
		END;
	buscaCodigo:= encontrado;
END;{FIN de buscaCodigo}

FUNCTION VerificarUsuario(VAR enumerado1:tUsuarios; usuario2:tUsuario; codigo1:string):integer;
VAR
	i,j:integer;
BEGIN
	WITH enumerado1 DO
		IF tope < MAXUSUARIOS THEN {A partir de este IF registramos el producto}
		BEGIN {Hay sitio en el listado}
			i:=0;
			REPEAT
				i:= i+1;
			UNTIL (i=tope) OR (codigo1=usuarios[i].codigoTarjeta);
			IF (codigo1=usuarios[i].codigoTarjeta) THEN{Esta repetido}
				VerificarUsuario:=i
			ELSE
				VerificarUsuario:=0;
		END{IF}
		ELSE
			writeln('El listado esta lleno, no se puede agregar');
END;{FIN de VerificarUsuario}

PROCEDURE EscribirFicheroProductos(VAR ficheroProductos1:tArchivoProductos; listado1:tProductos);
VAR
	i:integer;
BEGIN
	assign(ficheroProductos1,'C:\fichero\productos.dat');
	rewrite(ficheroProductos1);
	WITH listado1 DO
	FOR i := 1 TO tope-1 DO
 		write(ficheroProductos1,productos[i]);
    close(ficheroProductos1);
END;{FIN de EscribirFicheroProductos}

PROCEDURE EscribirFicheroUsuarios(VAR ficheroUsuarios1:tArchivoUsuarios; enumerado1:tUsuarios);
VAR
	i:integer;
BEGIN
	assign(ficheroUsuarios1,'C:\fichero\usuarios.dat');
	rewrite(ficheroUsuarios1);
	WITH enumerado1 DO
	FOR i := 1 TO tope-1 DO
 		write(ficheroUsuarios1,usuarios[i]);
    close(ficheroUsuarios1);
END;{FIN de EscribirFicheroUsuarios}

PROCEDURE EscribirFicheroVentas(VAR ficheroVentas1:tArchivoVentas; listadoVentas1:tVentas);
VAR
	i:integer;
BEGIN
	assign(ficheroVentas1,'C:\fichero\ventas.dat');
	rewrite(ficheroVentas1);
	WITH listadoVentas1 DO
	FOR i := 1 TO tope DO
 		write(ficheroVentas1,ventas[i]);
    close(ficheroVentas1);
END;{FIN de EscribirFicheroVentas}

PROCEDURE InsertarUsuario(VAR enumerado1:tUsuarios; usuario2:tUsuario);
VAR
	i,j:integer;
BEGIN
	WITH enumerado1 DO
		IF tope < MAXPRODUCTOS THEN {A partir de este IF registramos el producto}
		BEGIN {Hay sitio en el listado}
			i:=0;
			REPEAT
				i:= i+1;
			UNTIL (i=tope) OR (usuario2.codigoTarjeta=usuarios[i].codigoTarjeta);
			IF (usuario2.codigoTarjeta=usuarios[i].codigoTarjeta) THEN{Esta repetido}
				writeln('El usuario ya esta registrado')
			ELSE
			BEGIN
				tope := tope + 1;
				usuarios[i] := usuario2;
			END;{ELSE}
		END{IF}
		ELSE
			writeln('El listado esta lleno, no se puede agregar');
END;{FIN de InsertarUsuario}

PROCEDURE NoHanComprado(listadoVentas1:tVentas; enumerado1:tUsuarios);
VAR
	i,contador,j,registrador:integer;
BEGIN
	registrador:=0;
	FOR i:=1 TO enumerado1.tope DO
		BEGIN
		contador:=0;
		FOR j:=1 TO listadoVentas1.tope DO
			IF enumerado1.usuarios[i].codigoTarjeta=listadoVentas1.ventas[j].codigoTarjeta THEN
				contador:=contador+1;
		IF contador=0 THEN
			BEGIN
			writeln('-',enumerado1.usuarios[i].nombre);
			registrador:=registrador+1;
			END;{IF}
		END;{FOR}
	IF registrador=0 THEN
		writeln('Todos los usuarios han comprado al menos 1 producto');
END;{FIN de NoHanComprado}

FUNCTION EliminarUsuario(VAR enumerado1:tUsuarios; registro1:integer; codigo1:tCodigoTarjeta):tUsuario;
VAR
	i,j,stop:integer;
BEGIN {eliminar Producto}
	WITH enumerado1 DO
	BEGIN
	delete(usuarios[registro1].nombre,1,100);
	delete(usuarios[registro1].codigoTarjeta,1,100);
	usuarios[registro1].saldo:=0;
	writeln;
	writeln('Se ha eliminado correctamente');
	EliminarUsuario:=usuarios[registro1];
	END;
END;{FIN de EliminarUsuario}

FUNCTION OrdenarUsuarios(enumerado1:tUsuarios; registro1:integer): tUsuarios;
VAR
	i:integer;
BEGIN
	FOR i:=succ(registro1) TO enumerado1.tope DO
		BEGIN
			enumerado1.usuarios[i-1]:=enumerado1.usuarios[i]
		END;{FOR}
	enumerado1.tope:=enumerado1.tope-1;{Con esta operacion reducimos el tamaño de la agenda a 1 ya que habremos
	eliminado un contacto}
	OrdenarUsuarios:=enumerado1;
END;{FIN de OrdenarUsuarios}

PROCEDURE ProductosComprados(listadoVentas1:tVentas);
VAR
	contador,i:integer;
BEGIN
	contador:=0;
	WITH listadoVentas1 DO
		FOR i:=1 TO tope DO
			IF ventas[i].nombreProducto<>'' THEN
				BEGIN
				contador:=0;
				contador:=contador+1;
				writeln('Se ha comprado ',contador,' unidad de ',listadoVentas1.ventas[i].nombreProducto);
				END;
END;{FIN de ProductosComprados}


PROCEDURE EscribirFicheroVentasPersonalizado(listadoVentas1:tVentas; rutaVentasPersonalizado:string);
VAR
	i:integer;
	ficheroVentas:text;
BEGIN
	assign(ficheroVentas,rutaVentasPersonalizado);{La ruta es definida en el programa principal}
	rewrite(ficheroVentas);
	WITH listadoVentas1 DO BEGIN
		FOR i:=1 TO tope DO BEGIN
			writeln(ficheroVentas,listadoVentas1.ventas[i].nombreProducto);
			writeln(ficheroVentas,listadoVentas1.ventas[i].codigoTarjeta);
			writeln(ficheroVentas,listadoVentas1.ventas[i].fecha);
		END;
	END;{WITH}
	close(ficheroVentas);
END;{FIN de EscribirFicheroVentasPersonalizado}

PROCEDURE InsertarVenta(VAR listadoVentas1:tVentas; articulo1:string; codigoCliente1:string; fecha1:string);
VAR
	i,j:integer;
BEGIN
	WITH listadoVentas1 DO
		IF tope < MAXVENTAS THEN {A partir de este IF registramos el producto}
		BEGIN {Hay sitio en el listado}
			tope := tope + 1;
			ventas[tope].nombreProducto:= articulo1;
			ventas[tope].codigoTarjeta:= codigoCliente1;
			ventas[tope].fecha:= fecha1;
			writeln('La venta se ha realizado correctamente');
		END{IF}
		ELSE
			writeln('El listado de ventas esta lleno, no se puede agregar');
END;{FIN de InsertarVenta}

PROCEDURE hacerBackupProductos(VAR backupProductos:tArchivoProductos; listado1:tProductos);
VAR
	i:integer;
BEGIN
	assign(backupProductos,'C:\fichero\backupProductos.dat');
	rewrite(backupProductos);
	WITH listado1 DO
	FOR i := 1 TO tope-1 DO
 		write(backupProductos,productos[i]);
    close(backupProductos);
END;{FIN de hacerBackupProductos}

PROCEDURE hacerBackupUsuarios(VAR backupUsuarios:tArchivoUsuarios; enumerado1:tUsuarios);
VAR
	i:integer;
BEGIN
	assign(backupUsuarios,'C:\fichero\backupUsuarios.dat');
	rewrite(backupUsuarios);
	WITH enumerado1 DO
	FOR i := 1 TO tope-1 DO
 		write(backupUsuarios,usuarios[i]);
    close(backupUsuarios);
END;{FIN de hacerBackupUsuarios}

PROCEDURE hacerBackupVentas(VAR backupVentas:tArchivoVentas; listadoVentas1:tVentas);
VAR
	i:integer;
BEGIN
	assign(backupVentas,'C:\fichero\backupVentas.dat');
	rewrite(backupVentas);
	WITH listadoVentas1 DO
	FOR i := 1 TO tope DO
 		write(backupVentas,ventas[i]);
    close(backupVentas);
END;{FIN de hacerBackupVentas}

PROCEDURE escribirVentas(venta1:tVenta);
BEGIN
	WITH venta1 DO
		writeln('-Producto: ',nombreProducto,' |  Comprador: ',Codigotarjeta,' |  Fecha: ',fecha);
END;{FIN de escribirVentas}

PROCEDURE listadoDeVentas(listadoVentas1:tVentas);
VAR
	i:integer;
BEGIN
	WITH listadoVentas1 DO BEGIN
		IF tope=0 THEN
			writeln('No se ha vendido nada')
		ELSE BEGIN
		  FOR i:=1 TO tope DO
			escribirVentas(ventas[i]);
	    END;
	END;
END;{FIN de listadoVentas}

PROCEDURE leerBackupProductos(VAR backupProductos:tArchivoProductos; VAR listado1:tProductos);
VAR
	i,j:integer;
BEGIN
	i:=0;
	assign(backupProductos,'C:\fichero\backupProductos.dat');
    {$I-}
	reset(backupProductos);
	{$I+}
	IF (IOResult=0) THEN
	BEGIN
		REPEAT
			BEGIN
				i:=i+1;
				read(backupProductos,listado1.productos[i]);
			END;
		UNTIL EOF(backupProductos);
		close(backupProductos);
		listado1.tope:=i+1;
	END
	ELSE
		writeln('No existe el archivo binario');
END;{FIN de leerBackupProductos}

PROCEDURE leerBackupUsuarios(VAR backupUsuarios:tArchivoUsuarios; VAR enumerado1:tUsuarios);
VAR
	i,j:integer;
BEGIN
	i:=0;
	assign(backupUsuarios,'C:\fichero\backupUsuarios.dat');
    {$I-}
	reset(backupUsuarios);
	{$I+}
	IF (IOResult=0) THEN
	BEGIN
		REPEAT
			BEGIN
				i:=i+1;
				read(backupUsuarios,enumerado1.usuarios[i]);

			END;
		UNTIL EOF(backupUsuarios);
		close(backupUsuarios);
		enumerado1.tope:=i+1;
	END
	ELSE
		writeln('No existe el fichero binario.');
END;{FIN de leerBackupUsuarios}

PROCEDURE leerBackupVentas(VAR backupVentas:tArchivoVentas; VAR listadoVentas1:tVentas);
VAR
	i:integer;
BEGIN
	i:=0;
	assign(backupVentas,'C:\fichero\backupVentas.dat');
    {$I-}
	reset(backupVentas);
	{$I+}
	IF (IOResult=0) THEN BEGIN
		REPEAT
			BEGIN
				i:=i+1;
				read(backupVentas,listadoVentas1.ventas[i]);

			END;
		UNTIL EOF(backupVentas);
		close(backupVentas);
		listadoVentas1.tope:=i;
		END
	ELSE writeln('No existe el fichero binario.');
END;{FIN de leerBackupVentas}


VAR{Variables Principales}
	codigo:tCodigoTarjeta;
	usuario:tUsuarios;
	introducido,buscador:integer;
	nuevocodigo:tCodigoTarjeta;
	decision,nombreBorrar:string;
	registro,registro1:integer;
	nombre:string;
	saldo:real;
	FicheroUsuarios:tArchivoUsuarios;
	FicheroProductos:tArchivoProductos;
	FicheroVentas:tArchivoVentas;
	respuesta:string;
	usuarios:tListaUsuarios;
	introduce:integer;
	fecha:tFecha;
	menu:char;
	resultado:integer;
	i:integer;
	ruta,rutaPersonalizada,rutaUsuario,rutaVentas:string;
	listado:tProductos;
	objetos:tProducto;
	fichero:tArchivoProductos;
    tarjeta:tUsuarios;
	enumerado:tUsuarios;
	usuario1:tUsuario;
	buscado:integer;
	saldoinicial1:real;
	codigoBorrar:string;
	articulo:string;
	nombreCliente,crearGuardarVentas:string;
	saldoCliente:real;
	codigoCliente:string;
	listadoVentas:tVentas;
	venta:tVenta;
	ingreso:real;
	option,escogeBackup:string;
	obtenido:integer;

BEGIN{Programa Principal}

	writeln('Introduce la fecha(ej:2019-11-28):');
	readln(fecha);
	leerProductos(ficheroProductos,listado);
	leerUsuarios(ficheroUsuarios,enumerado);
	leerVentas(ficheroVentas,listadoVentas);
	REPEAT
		writeln('Introduce el codigo de la tarjeta:');
		readln(codigo);
		writeln;
		IF codigo='0000' THEN{A partir de aqui menu del REPONEDOR}
			REPEAT
				MenuReponedor;
				readln(menu);
				CASE menu OF
					'a','A':BEGIN
							writeln('**** Venta de tarjeta ****');
							IF enumerado.tope>MAXUSUARIOS THEN
								writeln('La lista de usuarios esta llena')
							ELSE
								BEGIN
								WITH usuario1 DO
									BEGIN
									writeln('Introduce el nombre:');
									readln(nombre);
									REPEAT
										writeln('Introduce el codigo de la tarjeta:');
										readln(codigoTarjeta);
										writeln('Introduce el saldo inicial:');
										readln(saldo);
										saldoinicial1:=usuario1.saldo;
										registro:=VerificarUsuario(enumerado,usuario1,codigoTarjeta);
										writeln;
										IF registro<>0 THEN
											writeln('Ya existen un usuario con este codigo')
										ELSE
											BEGIN
											InsertarUsuario(enumerado,usuario1);
											EscribirFicheroUsuarios(ficheroUsuarios,enumerado);
											writeln('Se ha registrado correctamente');
											END;{ELSE}
									UNTIL registro=0;
									END;{WITH}
								END;{ELSE}
							END;{FIN de Venta de Tarjeta}
					'b','B':BEGIN
							writeln('**** Baja tarjeta ****');
							writeln('Lista De Usuarios:');
							listadoUsuarios(enumerado);
							writeln;
							writeln('Introduce el codigo del usuario que quieras borrar:');
							readln(codigoBorrar);
							registro1:=buscaCodigo(enumerado,codigoBorrar);
							IF registro1=0 THEN
								writeln('No existe ningun usuario con este codigo!')
							ELSE
								BEGIN
								enumerado.usuarios[registro1]:=EliminarUsuario(enumerado,registro1,codigoBorrar);
								enumerado:=OrdenarUsuarios(enumerado,registro1);
								EscribirFicheroUsuarios(ficheroUsuarios,enumerado);
								END;{ELSE}
							END;
					'c','C':BEGIN
							writeln('**** Agregar producto ****');
								writeln('Introduce el nombre del producto');
								readln(objetos.nombre);
								obtenido:=LeerProducto(listado,objetos.nombre);
								IF obtenido=0 THEN
									BEGIN
									insertarProducto(listado,objetos);
									EscribirFicheroProductos(ficheroProductos,listado);
									END
								ELSE IF obtenido=1 THEN
									BEGIN
									writeln('Introduce el nombre de la marca');
									readln(objetos.marca);
									writeln('Introduce el precio');
									readln(objetos.precio);
									WHILE objetos.precio<=0 DO BEGIN
										writeln('Precio incorrecto.Introduce el precio:');
										readln(objetos.precio);
										END;{WHILE}
									writeln('Introduce el stock');
									readln(objetos.stock);
									writeln;
									insertarProducto(listado,objetos);
									EscribirFicheroProductos(ficheroProductos,listado);
									END;{ELSE IF}
							END;{FIN de Añadir producto}
					'd','D':BEGIN
							writeln('**** Eliminar producto ****');
							writeln('Estos son los productos que hay ahora mismo ');
							listadoProductos(listado);
							writeln('-------------------------------------------------------------------------------------------');
							writeln('Introduce el nombre del producto que quiere eliminar: ');
							readln(nombreBorrar);
							buscaNombre(listado,nombreBorrar);
							buscador:=buscanombre(listado,nombreBorrar);
							IF (buscador=0) THEN
								writeln('Ese nombre  no corresponde con el listado.')
							ELSE BEGIN
							eliminarProducto(listado,nombreBorrar);
							EscribirFicheroProductos(ficheroProductos,listado);
							END;
							END;
					'e','E':BEGIN
							writeln('**** Listado productos ****');
							listadoProductos(listado);
							writeln('-------------------------------------------------------------------------------------------');
							END;
					'f','F':BEGIN
							writeln('**** Listado usuarios ****');
							listadoUsuarios(enumerado);
							END;
					'g','G':BEGIN
							writeln('**** Listado ventas ****');
							listadoDeVentas(listadoVentas);
							END;
					'h','H':BEGIN
							writeln('**** Listado de usuarios que no han comprado ****');
							leerVentas(ficheroVentas,listadoVentas);
							leerProductos(ficheroProductos,listado);
							NoHanComprado(listadoVentas,enumerado);
							END;
					'i','I':BEGIN
							writeln('**** Listado de productos que han sido vendidos ****');
							IF listadoVentas.tope=0 THEN
								writeln('No se ha comprado ningun producto todavia')
							ELSE
							leerVentas(ficheroVentas,listadoVentas);
							ProductosComprados(listadoVentas);
							END;
					'j','J':BEGIN
							writeln('**** Hacer backup ****');
							writeln('De que fichero quiere realizar la copia? ');
							writeln('Productos, Usuarios, Ventas, Todo');
							writeln('backup realizado');
							readln(escogeBackup);
							IF (escogeBackup = 'Productos') OR (escogeBackup='productos') THEN
								BEGIN
									hacerBackupProductos(ficheroProductos,listado);
									writeln('Backup realizado');
								END
							ELSE IF (escogeBackup= 'Usuarios') or (escogeBackup='Usuarios') THEN
								BEGIN
									hacerBackupUsuarios(ficheroUsuarios,enumerado);
									writeln('Backup realizado');
								END
							ELSE IF (escogeBackup= 'Ventas') or (escogeBackup='ventas') THEN
								BEGIN
									hacerBackupVentas(ficheroVentas,listadoVentas);
									writeln('Backup realizado');
								END
							ELSE IF (escogeBackup = 'todo') OR (escogeBackup='Todo') THEN
								BEGIN
									hacerBackupProductos(ficheroProductos,listado);
									hacerBackupUsuarios(ficheroUsuarios,enumerado);
									hacerBackupVentas(ficheroVentas,listadoVentas);
									writeln('Backup realizado');
								END
							ELSE writeln('Introduce una opcion correcta');
							writeln;
							END;
					'k','K': BEGIN
								writeln('**** Restaurar backup ****');
								writeln('De que fichero quiere resturar la copia? ');
								writeln('Productos, Usuarios, Ventas, Todo');
								readln(option);
								IF (option = 'Productos') or (option='productos') THEN
									BEGIN
										leerBackupProductos(ficheroProductos,listado);
										EscribirFicheroProductos(ficheroProductos,listado);
										writeln('Copia Restaurada con exito');

									END
								ELSE IF (option = 'usuarios') or (option='Usuarios') THEN
									BEGIN
										leerBackupUsuarios(ficheroUsuarios,enumerado);
										EscribirFicheroUsuarios(ficheroUsuarios,enumerado);
										writeln('Copia Restaurada con exito');
									END
								ELSE IF (option = 'ventas') or (option='Ventas') THEN
									BEGIN
										leerBackupVentas(ficheroVentas,listadoVentas);
										EscribirFicheroVentas(ficheroVentas,listadoVentas);
										writeln('Copia Restaurada con exito');
									END
								ELSE IF (option = 'todo') or (option='Todo') THEN
									BEGIN
										leerBackupUsuarios(ficheroUsuarios,enumerado);
										EscribirFicheroUsuarios(ficheroUsuarios,enumerado);
										leerBackupProductos(ficheroProductos,listado);
										EscribirFicheroProductos(ficheroProductos,listado);
										leerBackupVentas(ficheroVentas,listadoVentas);
										EscribirFicheroVentas(ficheroVentas,listadoVentas);
										writeln('Copia Restaurada con exito');
									END
								ELSE
								writeln('Selecciona una opcion correcta a la proxima');
							END;
					'l','L':BEGIN
							writeln('**** Guardar ventas ****');
							IF listadoVentas.tope=0 THEN
								writeln('No se han realizado ventas.No es posible guardar las ventas')
							ELSE
								BEGIN
								writeln('Introduce el nombre del archivo donde lo quieres guardar con la direccion donde quieras crearlo. EJ C:\fichero\ventasDiciembre.txt');

								readln(crearGuardarVentas);
								rutaPersonalizada:=crearGuardarVentas;
								EscribirFicheroVentasPersonalizado(listadoVentas,rutaPersonalizada);
								writeln('Ventas guardadas correctamente');
								END;{ELSE}
							END;
					'm','M':writeln;
				ELSE
					writeln('Opcion Incorrecta');
				END;{CASE}
			UNTIL (menu='m') OR (menu='M')
		ELSE{A partir de aqui menu del Comprador}
			BEGIN
				buscado:=VerificarUsuario(enumerado,usuario1,codigo);
				IF (buscado=0) OR (codigo='') THEN
					writeln('Este codigo no esta registrado')
				ELSE
					BEGIN
						writeln('----------------------------------------------------------');
						writeln('Bienvenido ',enumerado.usuarios[buscado].nombre);
						writeln('Su saldo acumulado es de ',enumerado.usuarios[buscado].saldo:0:2,' euros');
						writeln('----------------------------------------------------------');
						nombreCliente:=enumerado.usuarios[buscado].nombre;
						saldoCliente:=enumerado.usuarios[buscado].saldo;
						codigoCliente:=codigo;
						REPEAT
							MenuComprador;
							readln(menu);
								CASE menu OF
									'a','A':BEGIN
											writeln('**** Compra de producto ****');
											listadoProductos(listado);
											writeln('-------------------------------------------------------------------------------------------');
											writeln('Introduzca el nombre del producto:');
											readln(articulo);
											buscador:=buscanombre(listado,articulo);
											IF (buscador=0) THEN
												writeln('No hay ningun producto con ese nombre')
											ELSE BEGIN
												IF listado.productos[buscador].stock=0 THEN
													writeln('No quedan mas productos')
												ELSE BEGIN
													IF saldoCliente<listado.productos[buscador].precio THEN
														writeln('No dispones de dinero suficiente')
													ELSE BEGIN
														InsertarVenta(listadoVentas,articulo,codigoCliente,fecha);
														EscribirFicheroVentas(ficheroVentas,listadoVentas);

														listado.productos[buscador].stock:=listado.productos[buscador].stock-1;
														EscribirFicheroProductos(ficheroProductos,listado);
														enumerado.usuarios[buscado].saldo:=enumerado.usuarios[buscado].saldo-listado.productos[buscador].precio;
														EscribirFicheroUsuarios(ficheroUsuarios,enumerado)
													END;{ELSE}
												END;{ELSE}
											END;{ELSE}
											writeln;
											END;
									'b','B':BEGIN
											writeln('**** Meter dinero en la tarjeta ****');
											writeln('Deposita el dinero que quieres ingresar');
											readln(ingreso);
											enumerado.usuarios[buscado].saldo:=enumerado.usuarios[buscado].saldo+ingreso;
											EscribirFicheroUsuarios(ficheroUsuarios,enumerado);
											writeln('Dinero ingresado');
											writeln;
											END;
									'c','C':writeln;
								ELSE
									writeln('Opcion Incorrecta');
								END;{CASE}
						UNTIL (menu='c') OR (menu='C');
					END;{CASE}
			END;{ELSE}
		writeln;
	UNTIL (usuario.tope=100);
readln;
END.
