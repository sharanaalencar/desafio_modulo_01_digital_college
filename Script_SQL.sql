-- 01. Base escolhida: northwind.sql 
-- 02. Problema escolhido: Definição do Perfil dos Clientes por Categoria de Produtos
-- 03. Modelo Conceitual e Lógico: Criados no BR MODELO

 04. Criar a estrutura do Data Warehouse, utilizando os scripts em SQL:

 
-- CREATE TABLE data_warehouse.dim_categorias (
-- 	id_categoria SMALLINT PRIMARY KEY,
-- 	nome_categoria VARCHAR(255)
-- 	)
OK


-- CREATE TABLE data_warehouse.dim_produtos (
-- 	id_produto SMALLINT PRIMARY KEY,
-- 	nome_produto VARCHAR(255) NOT NULL,
-- 	id_categoria SMALLINT,
-- 	FOREIGN KEY (id_categoria) REFERENCES data_warehouse.dim_categorias (id_categoria),
-- 	preco_unid REAL
-- 	)
OK

-- CREATE TABLE data_warehouse.dim_clientes (
--     id_cliente CHAR PRIMARY KEY,
--     nome_empresa VARCHAR(255) NOT NULL,
--  	regiao VARCHAR (255),
-- 	pais VARCHAR(255)    
-- )
OK


-- CREATE TABLE data_warehouse.fato_pedidos (
-- 	id_pedido SMALLINT PRIMARY KEY,
-- 	id_cliente CHAR NOT NULL,
-- 	FOREIGN KEY (id_cliente) REFERENCES data_warehouse.dim_clientes (id_cliente),
-- 	data_pedido DATE
-- )
OK



-- CREATE TABLE data_warehouse.fato_pedido_detalhe (
-- 	id_pedido SMALLINT PRIMARY KEY,
-- 	FOREIGN KEY (id_pedido) REFERENCES data_warehouse.fato_pedidos (id_pedido),
-- 	id_produto SMALLINT,
--  	FOREIGN KEY (id_produto) REFERENCES data_warehouse.dim_produtos (id_produto),
-- 	preco_unidade REAL,
-- 	quantidade SMALLINT,
-- 	desconto REAL)



-- 05. Criar os scripts de ingestao de dados em SQL e alimentar o DW

INSERINDO DADOS NA TABELA: DIM_CATEGORIAS

-- INSERT INTO data_warehouse.dim_categorias (
-- 	id_categoria, nome_categoria) 
-- SELECT category_id, category_name 
-- FROM public.categories
OK


INSERINDO DADOS NA TABELA: DIM_CLIENTES

-- INSERT INTO data_warehouse.dim_clientes (
-- 	id_cliente, nome_empresa, regiao, pais) 
-- 	SELECT customer_id, company_name, region, country
-- 	FROM public.customers
	
-- ALTER TABLE data_warehouse.dim_clientes 
-- ALTER COLUMN id_cliente TYPE CHAR (10) USING id_cliente::CHAR(10);
	

INSERINDO DADOS NA TABELA: DIM_PRODUTOS

-- INSERT INTO data_warehouse.dim_produtos (
-- 	id_produto, nome_produto, id_categoria, preco_unid) 
-- 	SELECT product_id, product_name, category_id, unit_price
-- 	FROM public.products

ok


INSERINDO DADOS NA TABELA: FATO_PEDIDOS

-- INSERT INTO data_warehouse.fato_pedidos (
-- 	id_pedido, id_cliente, data_pedido ) 
-- 	SELECT order_id, customer_id, order_date 
-- 	FROM public.orders

-- ALTER TABLE data_warehouse.fato_pedidos
-- ALTER COLUMN id_cliente TYPE CHAR (10) USING id_cliente::CHAR(10);

OK


INSERINDO DADOS NA TABELA: FATO_PEDIDO_DETALHE


-- INSERT INTO data_warehouse.fato_pedido_detalhe (id_pedido, id_produto, preco_unidade, quantidade, desconto)
-- SELECT order_id,
--        product_id,
--        unit_price,
--        quantity,
--        discount
-- FROM public.order_details
-- ON CONFLICT (id_pedido) DO NOTHING

OK


-- PRODUTO MAIS VENDIDO POR CATEGORIA

-- CREATE TABLE data_warehouse.fato_categoria_produto (
-- 	nome_categoria VARCHAR PRIMARY KEY,
-- 	nome_produto VARCHAR,
-- 	total_comprado SMALLINT
-- 	)

-- INSERT INTO data_warehouse.fato_categoria_produto
--     (nome_categoria, nome_produto, total_comprado)
-- SELECT DISTINCT ON (cat.nome_categoria) 
--     cat.nome_categoria, 
--     prod.nome_produto, 
--     SUM(fpd.quantidade) AS total_comprado
-- FROM 
--     data_warehouse.fato_pedido_detalhe fpd
-- JOIN 
--     data_warehouse.dim_produtos prod ON fpd.id_produto = prod.id_produto
-- JOIN 
--     data_warehouse.dim_categorias cat ON prod.id_categoria = cat.id_categoria
-- GROUP BY 
--     cat.nome_categoria, 
--     prod.nome_produto
-- ORDER BY 
--     cat.nome_categoria, 
--     total_comprado DESC;

-- ALTER TABLE data_warehouse.dim_categorias
-- ADD CONSTRAINT unique_nome_categoria UNIQUE (nome_categoria);

-- ALTER TABLE data_warehouse.fato_categoria_produto
-- ADD CONSTRAINT fk_fato_categoria_produto_dim_categorias
-- FOREIGN KEY (nome_categoria) REFERENCES data_warehouse.dim_categorias (nome_categoria);
	
-- CATEGORIA QUE PREDOMINA POR PAÍS E VALOR COMPRADO

-- CREATE TABLE data_warehouse.fato_categoria_regiao (
-- 	nome_pais VARCHAR,
-- 	nome_categoria VARCHAR,
-- 	valor_total REAL
-- 	)

-- INSERT INTO data_warehouse.fato_categoria_regiao
--     (nome_pais, nome_categoria, valor_total)
-- SELECT DISTINCT ON (cli.pais) 
--     cli.pais, 
--     cat.nome_categoria, 
--     (SUM(fpd.quantidade * fpd.preco_unidade * (1 - fpd.desconto)))::numeric (18,2) AS valor_total
-- FROM 
--     data_warehouse.fato_pedidos fp
-- JOIN 
--     data_warehouse.fato_pedido_detalhe fpd ON fp.id_pedido = fpd.id_pedido
-- JOIN 
--     data_warehouse.dim_produtos prod ON fpd.id_produto = prod.id_produto
-- JOIN 
--     data_warehouse.dim_categorias cat ON prod.id_categoria = cat.id_categoria
-- JOIN 
--     data_warehouse.dim_clientes cli ON fp.id_cliente = cli.id_cliente
-- GROUP BY 
--     cli.pais, 
--     cat.nome_categoria
-- ORDER BY

--    cli.pais,
--    valor_total DESC;

-- ALTER TABLE data_warehouse.fato_categoria_regiao
-- ADD CONSTRAINT fk_fato_categoria_regiao_dim_categorias
-- FOREIGN KEY (nome_categoria) REFERENCES data_warehouse.dim_categorias (nome_categoria);

 -- VALOR DE PRODUTO POR CATEGORIA E PAIS
 
-- CREATE TABLE data_warehouse.fato_produto_regiao (
-- 	nome_pais VARCHAR,
-- 	nome_categoria VARCHAR,
-- 	quantidade_pedido SMALLINT,
-- 	valor_total REAL)

-- INSERT INTO data_warehouse.fato_produto_regiao
--     (nome_pais, nome_categoria, quantidade_pedido, valor_total)
-- SELECT cli.pais, 
-- 	cat.nome_categoria, 
-- 	COUNT(fp.id_pedido) AS quantidade_pedidos, 
-- 	(SUM(fpd.quantidade * fpd.preco_unidade * (1 - fpd.desconto)))::numeric(18,2) AS valor_total
-- FROM data_warehouse.fato_pedidos fp 
-- JOIN data_warehouse.fato_pedido_detalhe fpd 
-- 	ON fp.id_pedido = fpd.id_pedido 
-- JOIN data_warehouse.dim_produtos prod 
-- 	ON fpd.id_produto = prod.id_produto 
-- JOIN data_warehouse.dim_categorias cat 
-- 	ON prod.id_categoria = cat.id_categoria 
-- JOIN data_warehouse.dim_clientes cli 
-- 	ON fp.id_cliente = cli.id_cliente 
-- GROUP BY cli.pais, cat.nome_categoria 
-- ORDER BY SUM(fpd.quantidade * fpd.preco_unidade * (1 - fpd.desconto)) 
-- DESC;


-- ALTER TABLE data_warehouse.fato_produto_regiao
-- ADD CONSTRAINT fk_fato_produto_regiao_dim_categorias
-- FOREIGN KEY (nome_categoria) REFERENCES data_warehouse.dim_categorias (nome_categoria);


-- RECEITA GERADA POR CLIENTE

-- CREATE TABLE data_warehouse.fato_receita_cliente (
-- 	nome_empresa VARCHAR,
-- 	receita_total REAL)


-- INSERT INTO data_warehouse.fato_receita_cliente
--     (nome_empresa, receita_total)
-- SELECT 
--     cli.nome_empresa, 
--     SUM(fpd.quantidade * fpd.preco_unidade * (1 - fpd.desconto))::numeric(18, 2) AS receita_total
-- FROM 
--     data_warehouse.fato_pedidos fp
-- JOIN 
--     data_warehouse.fato_pedido_detalhe fpd ON fp.id_pedido = fpd.id_pedido
-- JOIN 
--     data_warehouse.dim_clientes cli ON fp.id_cliente = cli.id_cliente
-- GROUP BY 
--     cli.nome_empresa
-- ORDER BY 
--     receita_total DESC;

-- DROP TABLE data_warehouse.fato_receita_cliente

-- QUANTIDADE DE PEDIDO POR CLIENTE (com país)


-- CREATE TABLE data_warehouse.fato_pedidos_clientes (
-- 	nome_empresa VARCHAR,
-- 	nome_pais VARCHAR,
-- 	quantidade_total SMALLINT)


-- INSERT INTO data_warehouse.fato_pedidos_clientes
--     (nome_empresa, nome_pais, quantidade_total)
-- SELECT cli.nome_empresa, cli.pais, 
-- 	COUNT(fp.id_pedido) AS quantidade_total 
-- 	FROM data_warehouse.fato_pedidos fp 
-- JOIN data_warehouse.dim_clientes cli 
-- 	ON fp.id_cliente = cli.id_cliente 
-- GROUP BY cli.nome_empresa, cli.pais 
-- ORDER BY quantidade_total 
-- DESC;


-- ALTER TABLE data_warehouse.dim_clientes
-- ADD CONSTRAINT unique_nome_empresa UNIQUE (nome_empresa);

-- CREATE TABLE data_warehouse.dim_regiao
-- ADD CONSTRAINT fk_fato_pedidos_clientes_dim_clientes
-- FOREIGN KEY (nome_empresa) REFERENCES data_warehouse.dim_clientes (nome_empresa);




)

