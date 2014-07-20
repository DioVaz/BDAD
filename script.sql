--------------------------------------------------------------
-- File: script.sql											--
-- Content: script of a database for a chain of stores	    --
-- Course: "Bases de Dados"									--
-- 	Author: 	Diogo Vaz									--
--------------------------------------------------------------

.mode column
.header on


--- pragmas
PRAGMA encoding = "UTF-8";
--PRAGMA foreign_keys = TRUE;

--- drops all tables
DROP TABLE IF EXISTS Produto;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Armazem;
DROP TABLE IF EXISTS Loja;
DROP TABLE IF EXISTS Factura;
DROP TABLE IF EXISTS Compra;
DROP TABLE IF EXISTS QuantProdFact;
DROP TABLE IF EXISTS LojaProduto;
DROP TABLE IF EXISTS ArmazemProduto;
DROP TABLE IF EXISTS QuantProdComp;
DROP TABLE IF EXISTS QuantProdArm;
DROP TABLE IF EXISTS QuantProdLoj;
DROP TABLE IF EXISTS Fornecedor;
DROP TABLE IF EXISTS Empregado;
DROP TABLE IF EXISTS Posto;
DROP TABLE IF EXISTS Tipo;


--- creation of tables
-- Table: Tipo
CREATE TABLE Tipo ( 
    idTipo     INTEGER PRIMARY KEY AUTOINCREMENT,
    designacao VARCHAR NOT NULL,
    taxa       REAL    NOT NULL
                       CHECK ( taxa > 0 ) 
);


-- Table: Cliente
CREATE TABLE Cliente ( 
    idCliente INTEGER PRIMARY KEY AUTOINCREMENT,
    nome      VARCHAR NOT NULL,
    contacto  NUMERIC NOT NULL
                      CHECK ( length( contacto ) = 9 ),
    idTipo INTEGER,
    CONSTRAINT idTipo FOREIGN KEY(idTipo) REFERENCES Tipo (idTipo) 
                      ON DELETE SET NULL   
                      ON UPDATE CASCADE
);


-- Table: Posto
CREATE TABLE Posto ( 
    idPosto    INTEGER PRIMARY KEY AUTOINCREMENT,
    designacao VARCHAR NOT NULL,
    salario    REAL    NOT NULL
                       CHECK ( salario > 0 ) 
);


-- Table: Empregado
CREATE TABLE Empregado ( 
    idEmpregado INTEGER PRIMARY KEY AUTOINCREMENT,
    nome        VARCHAR NOT NULL,
    contacto    NUMERIC NOT NULL
                        UNIQUE
                        CHECK ( length( contacto ) = 9 ),
    idPosto INTEGER,
    CONSTRAINT idPosto  FOREIGN KEY (idPosto) REFERENCES Posto ( idPosto ) 
    					ON DELETE SET NULL   
                      	ON UPDATE CASCADE
);


-- Table: Produto
CREATE TABLE Produto ( 
    idProduto INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao      VARCHAR NOT NULL
                      UNIQUE,
    preco     REAL    NOT NULL
                      CHECK ( preco > 0 ) 
);


-- Table: Armazem
CREATE TABLE Armazem ( 
    idArmazem   INTEGER PRIMARY KEY AUTOINCREMENT,
    morada      VARCHAR NOT NULL
                        UNIQUE,
    idEmpregado INTEGER,
    CONSTRAINT idEmpregado FOREIGN KEY (idEmpregado) REFERENCES Empregado ( idEmpregado )
    					ON DELETE SET NULL   
                      	ON UPDATE CASCADE
);


-- Table: Fornecedor
CREATE TABLE Fornecedor ( 
    idFornecedor INTEGER PRIMARY KEY AUTOINCREMENT,
    nome         VARCHAR NOT NULL,
    morada       VARCHAR NOT NULL,
    contacto     NUMERIC NOT NULL
                         UNIQUE
                         CHECK ( length( contacto ) = 9 ) 
);


-- Table: Compra
CREATE TABLE Compra ( 
    idCompra     INTEGER PRIMARY KEY AUTOINCREMENT,
    idFornecedor INTEGER,
    idArmazem INTEGER,
    CONSTRAINT idFornecedor FOREIGN KEY (idFornecedor) REFERENCES Fornecedor ( idFornecedor )
    						ON DELETE SET NULL   
                      		ON UPDATE CASCADE,
    CONSTRAINT idArmazem   FOREIGN KEY (idArmazem) REFERENCES Armazem ( idArmazem )
    						ON DELETE SET NULL   
                      		ON UPDATE CASCADE
);


-- Table: QuantProdArm
CREATE TABLE QuantProdArm ( 
	idProduto INTEGER,
    idArmazem INTEGER,
    quantidade INTEGER NOT NULL
                       CHECK ( quantidade > 0 ),
    CONSTRAINT    pk_QuantProdArm PRIMARY KEY ( idProduto, idArmazem),
    CONSTRAINT idProduto FOREIGN KEY (idProduto) REFERENCES Produto ( idProduto )
    						ON DELETE SET NULL   
                      		ON UPDATE CASCADE,
    CONSTRAINT idArmazem  FOREIGN KEY (idArmazem) REFERENCES Armazem ( idArmazem )
                       ON DELETE SET NULL   
                       ON UPDATE CASCADE    
);


-- Table: Loja
CREATE TABLE Loja ( 
    idLoja      INTEGER PRIMARY KEY AUTOINCREMENT,
    morada      VARCHAR NOT NULL,
    idEmpregado INTEGER,
    idArmazem INTEGER,
    CONSTRAINT idEmpregado FOREIGN KEY (idEmpregado) REFERENCES Empregado ( idEmpregado )
                       ON DELETE SET NULL   
                       ON UPDATE CASCADE,
    CONSTRAINT idArmazem   FOREIGN KEY (idArmazem) REFERENCES Armazem ( idArmazem )
                       ON DELETE SET NULL   
                       ON UPDATE CASCADE 
);


-- Table: QuantProdLoj
CREATE TABLE QuantProdLoj ( 
	idProduto INTEGER,
    idLoja INTEGER,
    quantidade INTEGER NOT NULL
                       CHECK ( quantidade > 0 ),
	CONSTRAINT	pk_QuantProdLoj PRIMARY KEY ( idProduto, idLoja),
    CONSTRAINT idProduto  FOREIGN KEY (idProduto) REFERENCES Produto ( idProduto )
                       ON DELETE SET NULL   
                       ON UPDATE CASCADE,
    CONSTRAINT idLoja   FOREIGN KEY (idLoja) REFERENCES Loja ( idLoja )
                       ON DELETE SET NULL   
                       ON UPDATE CASCADE
);


-- Table: Factura
CREATE TABLE Factura ( 
    idFactura   INTEGER PRIMARY KEY AUTOINCREMENT,
    idCliente INTEGER,
    idLoja INTEGER,
    idEmpregado INTEGER,
    CONSTRAINT idCliente  FOREIGN KEY (idCliente) REFERENCES Cliente ( idCliente )
    					ON DELETE SET NULL   
                        ON UPDATE CASCADE,
    CONSTRAINT idLoja   FOREIGN KEY (idLoja) REFERENCES Loja ( idLoja )
    					ON DELETE SET NULL   
                        ON UPDATE CASCADE,
    CONSTRAINT idEmpregado FOREIGN KEY (idEmpregado) REFERENCES Empregado ( idEmpregado ) 
    					ON DELETE SET NULL   
                        ON UPDATE CASCADE
);



-- Table: QuantProdFact
CREATE TABLE QuantProdFact (
    idProduto INTEGER,
    idFactura INTEGER,
    quantidade INTEGER NOT NULL
                       CHECK ( quantidade > 0 ),
	CONSTRAINT	pk_QuantProdFact PRIMARY KEY ( idProduto, idFactura), 
    CONSTRAINT idFactura  FOREIGN KEY (idFactura) REFERENCES Factura ( idFactura )
    					ON DELETE SET NULL   
                        ON UPDATE CASCADE,
    CONSTRAINT idProduto   FOREIGN KEY (idProduto) REFERENCES Produto ( idProduto )
    					ON DELETE SET NULL   
                        ON UPDATE CASCADE
);

-- Table: QuantProdComp
CREATE TABLE QuantProdComp ( 
	idCompra INTEGER,
	idProduto INTEGER,
	quantidade INTEGER NOT NULL
                       CHECK ( quantidade > 0 ),
	CONSTRAINT	pk_QuantProdComp PRIMARY KEY ( idProduto, idCompra),
    CONSTRAINT idCompra  FOREIGN KEY (idCompra) REFERENCES Compra ( idCompra)
    					ON DELETE SET NULL   
                        ON UPDATE CASCADE,
    CONSTRAINT idProduto  FOREIGN KEY (idProduto) REFERENCES Produto ( idProduto )
    					ON DELETE SET NULL   
                        ON UPDATE CASCADE
);

--- defenition of triggers
--This trigger sets the idEmpregado from the store

CREATE TRIGGER DefaultEmpFact
       AFTER INSERT ON Factura
       WHEN NEW.idEmpregado ISNULL
BEGIN
    UPDATE Factura
       SET idEmpregado =( 
               SELECT idEmpregado
                 FROM Loja
                WHERE idLoja = NEW.idLoja 
           )
     WHERE idFactura = NEW.idFactura;
END;

--This trigger sets the default Tipo from the first row of Tipo

CREATE TRIGGER DefaultClienteTipo
       AFTER INSERT ON Cliente
       WHEN NEW.idTipo ISNULL
BEGIN
    UPDATE Cliente
       SET idTipo =( 
               SELECT MIN(idTipo)
                 FROM Tipo
           )
     WHERE idCliente = NEW.idCliente;
END;

--This trigger is not complete as it we need to pay attention to the number of idEmpregado from the list as the last one is set as default on the store

CREATE TRIGGER DefaultEmpregado
       AFTER INSERT ON Loja
       WHEN NEW.idEmpregado ISNULL
BEGIN
    UPDATE Loja
       SET idEmpregado =( 
               SELECT MAX( idEmpregado )
                 FROM Empregado 
           )
     WHERE idLoja = NEW.idLoja;
END;



--- insertion of data 
-- for tipo table 
INSERT INTO tipo VALUES(null,'Gold', 1.25); 
INSERT INTO tipo VALUES(null,'Silver', 1.50);
INSERT INTO tipo VALUES(null,'Bronze', 1.75);  

-- for cliente table
INSERT INTO cliente VALUES(null,'Jose Vaz', 912546897, 1);
INSERT INTO cliente VALUES(null,'Pedro Silva', 914578214, 1);
INSERT INTO cliente VALUES(null,'Leonor Silvestre', 914786897, 3);
INSERT INTO cliente VALUES(null,'Artur Sousa', 914527897, 2);
INSERT INTO cliente VALUES(null,'Mariana Cruz', 916486653, 1);

-- for posto table
INSERT INTO posto VALUES(null,'Logista independente', 400);
INSERT INTO posto VALUES(null,'Logista normal', 650);
INSERT INTO posto VALUES(null,'Responsável de armazem', 650);


-- for empregado table
INSERT INTO empregado VALUES(null,'Manuela Santos', 927538491,1);
INSERT INTO empregado VALUES(null,'Miguel Couto', 936475967,2);
INSERT INTO empregado VALUES(null,'Carlos Moura', 916539964,3);
INSERT INTO empregado VALUES(null,'Catarina Marques', 917644663,3);
INSERT INTO empregado VALUES(null,'Maria Simoes', 935573688,2);
INSERT INTO empregado VALUES(null,'Daniel Goncalves', 925433725,1);


-- for produto table
INSERT INTO produto VALUES(null,'Arquivador - tamanho 1', 20);
INSERT INTO produto VALUES(null,'Arquivador - tamanho 2', 20);
INSERT INTO produto VALUES(null,'Arquivador - tamanho 3', 20);
INSERT INTO produto VALUES(null,'Arquivador - tamanho 4', 20);
INSERT INTO produto VALUES(null,'Arquivador - tamanho 5', 20);
INSERT INTO produto VALUES(null,'Arquivador - moedas euro', 25);
INSERT INTO produto VALUES(null,'Arquivador - lomba especial', 50);
INSERT INTO produto VALUES(null,'Guarda moedas - tamanho 1', 7.5);
INSERT INTO produto VALUES(null,'Guarda moedas - tamanho 2', 7.5);
INSERT INTO produto VALUES(null,'Guarda moedas - tamanho 3', 7.5);
INSERT INTO produto VALUES(null,'Guarda moedas - tamanho 4', 7.5);
INSERT INTO produto VALUES(null,'Micas para notas', 10);
INSERT INTO produto VALUES(null,'Guilhotina', 75);


-- for armazem table
INSERT INTO armazem VALUES(null,'Trofa', 3);
INSERT INTO armazem VALUES(null,'Viseu', 4);


-- for fornecedor table
INSERT INTO fornecedor VALUES(null,'Marta Castro', 'Porto', 917536654);
INSERT INTO fornecedor VALUES(null,'Pedro Costa', 'Lisboa', 926354877);
INSERT INTO fornecedor VALUES(null,'Carla Matos', 'Coimbra', 967344287);
INSERT INTO fornecedor VALUES(null,'Fernando Pontes', 'Braga', 965422386);
INSERT INTO fornecedor VALUES(null,'Joana Ribeiro', 'Algarve', 915573654);

-- for compra table
INSERT INTO compra VALUES(null,1, 1);
INSERT INTO compra VALUES(null,2, 2);
INSERT INTO compra VALUES(null,3, 2);
INSERT INTO compra VALUES(null,4, 1);
INSERT INTO compra VALUES(null,5, 2);


-- for quantprodarm table
INSERT INTO quantprodarm VALUES(1, 1, 30);
INSERT INTO quantprodarm VALUES(2, 1, 77);
INSERT INTO quantprodarm VALUES(3, 1, 34);
INSERT INTO quantprodarm VALUES(4, 1, 21);
INSERT INTO quantprodarm VALUES(5, 1, 20);
INSERT INTO quantprodarm VALUES(6, 1, 3);
INSERT INTO quantprodarm VALUES(7, 1, 64);
INSERT INTO quantprodarm VALUES(8, 1, 78);
INSERT INTO quantprodarm VALUES(1, 2, 30);
INSERT INTO quantprodarm VALUES(2, 2, 77);
INSERT INTO quantprodarm VALUES(3, 2, 34);
INSERT INTO quantprodarm VALUES(4, 2, 21);
INSERT INTO quantprodarm VALUES(5, 2, 20);
INSERT INTO quantprodarm VALUES(6, 2, 3);
INSERT INTO quantprodarm VALUES(7, 2, 64);
INSERT INTO quantprodarm VALUES(8, 2, 78);




-- for loja table
INSERT INTO loja VALUES(null,'Porto', 1, 1);
INSERT INTO loja VALUES(null,'Braga', 2, 1);
INSERT INTO loja VALUES(null,'Lisboa', 5, 2);
INSERT INTO loja VALUES(null,'Lisboa', 6, 2);


-- for quantprodloj table
INSERT INTO quantprodloj VALUES(1, 1, 30);
INSERT INTO quantprodloj VALUES(2, 4, 77);
INSERT INTO quantprodloj VALUES(3, 3, 34);
INSERT INTO quantprodloj VALUES(4, 2, 21);
INSERT INTO quantprodloj VALUES(5, 1, 20);
INSERT INTO quantprodloj VALUES(6, 4, 3);
INSERT INTO quantprodloj VALUES(7, 2, 64);
INSERT INTO quantprodloj VALUES(8, 1, 78);
INSERT INTO quantprodloj VALUES(1, 3, 30);
INSERT INTO quantprodloj VALUES(2, 2, 77);
INSERT INTO quantprodloj VALUES(3, 4, 34);
INSERT INTO quantprodloj VALUES(4, 1, 21);
INSERT INTO quantprodloj VALUES(5, 4, 20);
INSERT INTO quantprodloj VALUES(6, 1, 3);
INSERT INTO quantprodloj VALUES(7, 3, 64);
INSERT INTO quantprodloj VALUES(8, 4, 78);

-- for factura table
INSERT INTO factura VALUES(null, 1, 2, 2);
INSERT INTO factura VALUES(null, 2, 1, 1);
INSERT INTO factura VALUES(null, 3, 3, 5);
INSERT INTO factura VALUES(null, 4, 1, 1);
INSERT INTO factura VALUES(null, 5, 4, 6);

-- for quantprodfact
INSERT INTO quantprodfact VALUES(1, 4, 3);
INSERT INTO quantprodfact VALUES(1, 6, 2);
INSERT INTO quantprodfact VALUES(1, 7, 6);
INSERT INTO quantprodfact VALUES(5, 4, 3);
INSERT INTO quantprodfact VALUES(2, 5, 6);
INSERT INTO quantprodfact VALUES(2, 4, 1);
INSERT INTO quantprodfact VALUES(2, 9, 10);
INSERT INTO quantprodfact VALUES(3, 13, 1); 
INSERT INTO quantprodfact VALUES(4, 10, 2);

-- for quanrprodcomp table
INSERT INTO quantprodcomp VALUES(1, 3, 5);
INSERT INTO quantprodcomp VALUES(2, 6, 8);
INSERT INTO quantprodcomp VALUES(3, 9, 11);
INSERT INTO quantprodcomp VALUES(4, 12, 20);
INSERT INTO quantprodcomp VALUES(5, 13, 1);

--Queries
--Número de facturas de x cliente em y loja e ordenar por IDfatura
 
SELECT Factura.idFactura, COUNT(*), Cliente.idCliente, Loja.idLoja
FROM Factura, Loja, Cliente
WHERE factura.idCliente=cliente.idCliente AND loja.idLoja=factura.idLoja GROUP BY Loja.idLoja;

--Listagem de empregados por loja
 
SELECT nome, Empregado.idEmpregado
FROM Empregado, Loja
WHERE Loja.idEmpregado=Empregado.idEmpregado
GROUP BY Loja.idLoja;
 
--Listagem de fornecedores por compra

  SELECT nome, Fornecedor.idFornecedor
FROM Fornecedor, Compra
WHERE Compra.idFornecedor=Fornecedor.idFornecedor
ORDER BY Compra.idCompra;
 

--Qual o cliente que tem mais facturas

SELECT MAX(nome)
FROM Cliente, Factura
WHERE Factura.idCliente=Cliente.idCliente;


--Produtos em stock no armazem

  SELECT descricao
  FROM QuantProdArm, Armazem, Produto
  WHERE (Armazem.idArmazem = QuantProdArm.idArmazem AND Produto.idProduto = QuantProdArm.idProduto);

--Selecionar os gerentes das lojas

  SELECT designacao
  FROM Empregado, Posto
  WHERE (Empregado.idEmpregado=Posto.idPosto AND designacao='Gerente');


--Produtos existentes em loja

  SELECT Produto.idProduto
  FROM Loja, Produto;
  

--Listagem de clientes organizados por tipo

  SELECT nome
  FROM Cliente, Tipo
  WHERE Cliente.idCliente=Tipo.idTipo
GROUP BY Tipo.designacao;