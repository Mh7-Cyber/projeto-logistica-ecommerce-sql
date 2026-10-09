-- =========================================================================
-- PROJETO DE ANÁLISE DE DADOS - OLIST E-COMMERCE (LOGÍSTICA)
-- Autor: Mh7-Cyber
-- Descrição: Consultas SQL focadas em cruzamento de tabelas (JOINs) e 
--            manipulação de datas para análise de SLA de entregas.
-- Tabelas usadas: olist_customers_dataset e olist_orders_dataset
-- =========================================================================

-- 1. TEMPO MÉDIO DE ENTREGA POR ESTADO (UF)
-- Cruza pedidos e clientes para descobrir quais estados sofrem mais com a demora.
SELECT 
	cus.customer_state AS estado,
	ROUND(AVG(TIMESTAMPDIFF(HOUR, order_purchase_timestamp, order_delivered_customer_date)),1) AS tempo_medio
from olist_customers_dataset cus
join olist_orders_dataset ped on cus.customer_id = ped.customer_id
WHERE order_status = 'delivered'
	AND order_delivered_customer_date IS NOT NULL
GROUP BY estado
ORDER BY tempo_medio ASC

-- 2. TAXA DE ENTREGAS COM ATRASO
-- Descobre a porcentagem de pedidos em que a data real de entrega ultrapassou a estimada.
SELECT 
	COUNT(*) AS `Total de pedidos`,
	SUM(order_estimated_delivery_date < order_delivered_customer_date) AS `Entregas atrasadas`,
	ROUND((SUM(order_estimated_delivery_date < order_delivered_customer_date)*100)/COUNT(*),2) AS `Taxa de atraso`
FROM olist_orders_dataset
WHERE order_status = 'delivered'
	AND order_delivered_customer_date IS NOT NULL;


-- 3. EVOLUÇÃO DE CANCELAMENTOS NO ANO DE 2018 (MÊS A MÊS)
-- Analisa a saúde das operações mês a mês filtrando pedidos que não deram certo.

SELECT 
	MONTH(order_purchase_timestamp) AS MES,
    COUNT(order_status) AS `Cancel/Mes`
	
FROM olist_orders_dataset
WHERE order_status = "canceled"
	AND YEAR(order_purchase_timestamp) = 2017
GROUP BY mes
ORDER BY mes DESC

