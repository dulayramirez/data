USE PRUEBA_TECNICA

CREATE TABLE [dbo].[TIPO_DOCUMENTO](
	[ID_TIPO_DOCUMENTO] [int] IDENTITY(1,1) PRIMARY KEY,
	[DESCRIPCION_TIPO_DOCUMENTO] [varchar] (100),
	[SIGLA_TIPO_DOCUMENTO] [varchar] (100)
)
GO

CREATE TABLE [dbo].[TIPO_CONTACTO](
	[ID_TIPO_CONTACTO] [int] IDENTITY(1,1) PRIMARY KEY,
	[DESCRIPCION_TIPO_CONTACTO] [varchar] (100)
)
GO

CREATE TABLE [dbo].[TIPO_CUENTA](
	[ID_TIPO_CUENTA] [int] IDENTITY(1,1) PRIMARY KEY,
	[DESCRIPCION_TIPO_CUENTA] [varchar] (100)
)
GO

CREATE TABLE [dbo].[TIPO_ESTADO](
	[ID_TIPO_ESTADO] [int] IDENTITY(1,1) PRIMARY KEY,
	[DESCRIPCION_TIPO_ESTADO] [varchar] (50),
	[SIGLA_TIPO_ESTADO] [varchar] (6)
)
GO

CREATE TABLE [dbo].[TIPO_CONDICION](
	[ID_TIPO_CONDICION] [int] IDENTITY(1,1) PRIMARY KEY,
	[DESCRIPCION_TIPO_CONDICION] [varchar] (10)
)
GO

CREATE TABLE [dbo].[CLIENTE](
    [ID_CLIENTE] [int] IDENTITY(1,1) PRIMARY KEY,
	[NOMBRES] [varchar] (300),
	[APELLIDOS] [varchar] (300),
	[FECHA_NACIMIENTO] [datetime],
	[ID_TIPO_DOCUMENTO] [int],
	[NUMERO_DOCUMENTO] [varchar] (50),
	FOREIGN KEY (ID_TIPO_DOCUMENTO) REFERENCES TIPO_DOCUMENTO(ID_TIPO_DOCUMENTO)
) 
GO

CREATE TABLE [dbo].[CONTACTO](
    [ID_CONTACTO] [int] IDENTITY(1,1) PRIMARY KEY,
	[ID_CLIENTE] [int],
	[ID_TIPO_CONTACTO] [int],
	[VALOR_CONTACTO] [varchar] (600),
	FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTE(ID_CLIENTE),	
	FOREIGN KEY (ID_TIPO_CONTACTO) REFERENCES TIPO_CONTACTO(ID_TIPO_CONTACTO)
) 
GO

CREATE TABLE [dbo].[CUENTA](
    [ID_CUENTA] [int] IDENTITY(1,1) PRIMARY KEY,
	[NUMERO_CUENTA] [int],
	[ID_CLIENTE] [int],
	[ID_TIPO_CUENTA] [int],	
	[CREDITO_LIMITE] [int],
	[FECHA_APERTURA] [datetime],
	[ID_ESTADO] [int],	
	FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTE(ID_CLIENTE),	
	FOREIGN KEY (ID_TIPO_CUENTA) REFERENCES TIPO_CUENTA(ID_TIPO_CUENTA),	
	FOREIGN KEY (ID_ESTADO) REFERENCES TIPO_ESTADO(ID_TIPO_ESTADO)
) 
GO

CREATE TABLE [dbo].[NOTA_CREDITO_DEBITO](
    [ID_NOTA_CREDITO_DEBITO] [int] IDENTITY(1,1) PRIMARY KEY,
	[ID_CUENTA] [int],
	[ES_NOTA_CREDITO] [int],
	[FECHA_REGISTRO] [datetime],
	[VALOR_NOTA_CREDITO_DEBITO] [int],	
	FOREIGN KEY (ID_CUENTA) REFERENCES CUENTA(ID_CUENTA),	
	FOREIGN KEY (ES_NOTA_CREDITO) REFERENCES TIPO_CUENTA(ID_TIPO_CUENTA)
) 
GO

CREATE VIEW V_LISTA_CONTACTOS
AS
SELECT c.ID_CLIENTE,
STRING_AGG(p.DESCRIPCION_TIPO_CONTACTO,' , ') WITHIN GROUP (ORDER BY c.ID_CLIENTE) as TIPO_CONTACTO,
STRING_AGG(n.VALOR_CONTACTO,' , ') WITHIN GROUP (ORDER BY c.ID_CLIENTE) as CONTACTOS
FROM CLIENTE AS c
INNER JOIN CONTACTO AS n ON c.ID_CLIENTE = n.ID_CLIENTE
INNER JOIN TIPO_CONTACTO AS p ON n.ID_TIPO_CONTACTO = p.ID_TIPO_CONTACTO
group by c.ID_CLIENTE
GO

CREATE VIEW V_LISTA_SUMA_DEBITO
AS
SELECT c.ID_CLIENTE,
SUM (a.VALOR_NOTA_CREDITO_DEBITO) AS VALOR_NOTA_CREDITO_DEBITO, 
STRING_AGG(a.VALOR_NOTA_CREDITO_DEBITO,' , ') WITHIN GROUP (ORDER BY c.ID_CLIENTE) as VALOR_NOTA_CREDITO_DEBITO_INDIVIDUAL,
STRING_AGG(o.DESCRIPCION_TIPO_CUENTA,' , ') WITHIN GROUP (ORDER BY c.ID_CLIENTE) as TIPO_CUENTA,
STRING_AGG(u.NUMERO_CUENTA,' , ') WITHIN GROUP (ORDER BY c.ID_CLIENTE) as NUMERO_CUENTA,
STRING_AGG(u.FECHA_APERTURA,' , ') WITHIN GROUP (ORDER BY c.ID_CLIENTE) as FECHA_APERTURA,
STRING_AGG(u.CREDITO_LIMITE,' , ') WITHIN GROUP (ORDER BY c.ID_CLIENTE) as CREDITO_LIMITE,
STRING_AGG(d.DESCRIPCION_TIPO_ESTADO,' , ') WITHIN GROUP (ORDER BY c.ID_CLIENTE) as ESTADO,
STRING_AGG(p.DESCRIPCION_TIPO_CONTACTO,' , ') WITHIN GROUP (ORDER BY c.ID_CLIENTE) as TIPO_CONTACTO,
STRING_AGG(n.VALOR_CONTACTO,' , ') WITHIN GROUP (ORDER BY c.ID_CLIENTE) as CORREO
FROM CLIENTE AS c
INNER JOIN CUENTA AS u ON c.ID_CLIENTE = u.ID_CLIENTE
INNER JOIN TIPO_CUENTA AS o ON u.ID_TIPO_CUENTA = o.ID_TIPO_CUENTA
INNER JOIN TIPO_ESTADO AS d ON u.ID_ESTADO = d.ID_TIPO_ESTADO
INNER JOIN NOTA_CREDITO_DEBITO AS a ON u.ID_CUENTA = a.ID_CUENTA
INNER JOIN TIPO_CONDICION AS e ON a.ES_NOTA_CREDITO = e.ID_TIPO_CONDICION
INNER JOIN CONTACTO AS n ON c.ID_CLIENTE = n.ID_CLIENTE
INNER JOIN TIPO_CONTACTO AS p ON n.ID_TIPO_CONTACTO = p.ID_TIPO_CONTACTO
WHERE u.ID_TIPO_CUENTA = 5 AND u.ID_ESTADO = 1 AND n.ID_TIPO_CONTACTO = 1
group by c.ID_CLIENTE
GO

CREATE VIEW V_CUENTAS_CREDITO_ACTIVAS
AS
SELECT c.ID_CLIENTE, c.NOMBRES, c.APELLIDOS, c.FECHA_NACIMIENTO, t.DESCRIPCION_TIPO_DOCUMENTO, c.NUMERO_DOCUMENTO, p.DESCRIPCION_TIPO_CONTACTO, n.VALOR_CONTACTO
FROM CLIENTE AS c
INNER JOIN TIPO_DOCUMENTO AS t ON c.ID_TIPO_DOCUMENTO = t.ID_TIPO_DOCUMENTO
INNER JOIN CUENTA AS u ON c.ID_CLIENTE = u.ID_CLIENTE
INNER JOIN TIPO_CUENTA AS o ON u.ID_TIPO_CUENTA = o.ID_TIPO_CUENTA
INNER JOIN CONTACTO AS n ON c.ID_CLIENTE = n.ID_CLIENTE
INNER JOIN TIPO_CONTACTO AS p ON n.ID_TIPO_CONTACTO = p.ID_TIPO_CONTACTO
WHERE u.ID_TIPO_CUENTA  = 4 AND u.ID_ESTADO = 1 AND n.ID_TIPO_CONTACTO = 1
GO

---Obtener datos personales y de contacto de los clientes 
---que hayan cumplido un a�o con una de
---sus cuentas. Nota: calcular fecha excluir hora.

SELECT c.NOMBRES, c.APELLIDOS, c.FECHA_NACIMIENTO, t.DESCRIPCION_TIPO_DOCUMENTO, c.NUMERO_DOCUMENTO, 
n.TIPO_CONTACTO, n.CONTACTOS, u.NUMERO_CUENTA, o.DESCRIPCION_TIPO_CUENTA, 
u.FECHA_APERTURA, d.DESCRIPCION_TIPO_ESTADO
FROM CLIENTE AS c
INNER JOIN TIPO_DOCUMENTO AS t ON c.ID_TIPO_DOCUMENTO = t.ID_TIPO_DOCUMENTO
INNER JOIN V_LISTA_CONTACTOS AS n ON c.ID_CLIENTE = n.ID_CLIENTE
INNER JOIN CUENTA AS u ON c.ID_CLIENTE = u.ID_CLIENTE
INNER JOIN TIPO_CUENTA AS o ON u.ID_TIPO_CUENTA = o.ID_TIPO_CUENTA
INNER JOIN TIPO_ESTADO AS d ON u.ID_ESTADO = d.ID_TIPO_ESTADO
WHERE u.FECHA_APERTURA = Dateadd(year,-1, convert(date,CONVERT(char(10), GETDATE(), 103),103))
AND u.ID_ESTADO = 1;

---Obtener datos personales y de contacto de los clientes 
---con cuentas tipo cr�dito con un pasivo
---menor o igual a $200.000.

SELECT c.NOMBRES, c.APELLIDOS, c.FECHA_NACIMIENTO, t.DESCRIPCION_TIPO_DOCUMENTO, c.NUMERO_DOCUMENTO, 
n.TIPO_CONTACTO, n.CONTACTOS, u.NUMERO_CUENTA, o.DESCRIPCION_TIPO_CUENTA, 
u.FECHA_APERTURA, d.DESCRIPCION_TIPO_ESTADO, e.DESCRIPCION_TIPO_CONDICION AS ES_NOTA_CREDITO, 
a.FECHA_REGISTRO AS FECHA_REGISTRO_NOTA, a.VALOR_NOTA_CREDITO_DEBITO
FROM CLIENTE AS c
INNER JOIN TIPO_DOCUMENTO AS t ON c.ID_TIPO_DOCUMENTO = t.ID_TIPO_DOCUMENTO
INNER JOIN V_LISTA_CONTACTOS AS n ON c.ID_CLIENTE = n.ID_CLIENTE
INNER JOIN CUENTA AS u ON c.ID_CLIENTE = u.ID_CLIENTE
INNER JOIN TIPO_CUENTA AS o ON u.ID_TIPO_CUENTA = o.ID_TIPO_CUENTA
INNER JOIN TIPO_ESTADO AS d ON u.ID_ESTADO = d.ID_TIPO_ESTADO
INNER JOIN NOTA_CREDITO_DEBITO AS a ON u.ID_CUENTA = a.ID_CUENTA
INNER JOIN TIPO_CONDICION AS e ON a.ES_NOTA_CREDITO = e.ID_TIPO_CONDICION
WHERE u.ID_TIPO_CUENTA  = 4 AND u.ID_ESTADO = 1 AND a.VALOR_NOTA_CREDITO_DEBITO <= 200000;

---Obtener los datos de las cuentas tipo cr�dito 
---cuyo pasivo sea mayor o igual a su l�mite de
---cr�dito.

SELECT c.NOMBRES, c.APELLIDOS, c.FECHA_NACIMIENTO, t.DESCRIPCION_TIPO_DOCUMENTO, c.NUMERO_DOCUMENTO, 
n.TIPO_CONTACTO, n.CONTACTOS, u.NUMERO_CUENTA, o.DESCRIPCION_TIPO_CUENTA, 
u.FECHA_APERTURA, d.DESCRIPCION_TIPO_ESTADO, u.CREDITO_LIMITE,
e.DESCRIPCION_TIPO_CONDICION AS ES_NOTA_CREDITO, 
a.FECHA_REGISTRO AS FECHA_REGISTRO_NOTA, a.VALOR_NOTA_CREDITO_DEBITO
FROM CLIENTE AS c
INNER JOIN TIPO_DOCUMENTO AS t ON c.ID_TIPO_DOCUMENTO = t.ID_TIPO_DOCUMENTO
INNER JOIN V_LISTA_CONTACTOS AS n ON c.ID_CLIENTE = n.ID_CLIENTE
INNER JOIN CUENTA AS u ON c.ID_CLIENTE = u.ID_CLIENTE
INNER JOIN TIPO_CUENTA AS o ON u.ID_TIPO_CUENTA = o.ID_TIPO_CUENTA
INNER JOIN TIPO_ESTADO AS d ON u.ID_ESTADO = d.ID_TIPO_ESTADO
INNER JOIN NOTA_CREDITO_DEBITO AS a ON u.ID_CUENTA = a.ID_CUENTA
INNER JOIN TIPO_CONDICION AS e ON a.ES_NOTA_CREDITO = e.ID_TIPO_CONDICION
WHERE u.ID_TIPO_CUENTA  = 4 AND u.ID_ESTADO = 1 AND a.VALOR_NOTA_CREDITO_DEBITO >= u.CREDITO_LIMITE;

---Obtener los correos electr�nicos de clientes con un 
---activo mayor o igual a $1.000.000 sumado en sus cuentas ---tipo d�bito y que a�n no tienen una cuenta tipo cr�dito.

SELECT CORREO FROM V_LISTA_SUMA_DEBITO
WHERE 
VALOR_NOTA_CREDITO_DEBITO >= 1000000
EXCEPT
select VALOR_CONTACTO from V_CUENTAS_CREDITO_ACTIVAS






