# Análise de Performance Logística e Saúde das Operações (Olist)

## Visão Geral do Projeto
Este projeto analisa os dados de logística e o comportamento de entrega do e-commerce brasileiro para apoiar a tomada de decisões estratégicas de expansão e eficiência operacional. O foco está na identificação de gargalos de entrega por região geográfica, mapeamento das taxas de atraso em nível nacional e monitoramento de anomalias operacionais através do cancelamento de pedidos.

## Modelo de Dados
Os dados estruturados para esta análise consolidam métricas de fluxo de pedidos e perfis geográficos através de tabelas específicas do ecossistema Olist:
* **Métricas do Pedido (olist_orders_dataset):** Código identificador do pedido, relacionamento com o cliente, status da compra (ex: entregue, cancelado) e os carimbos de data/hora (timestamps) de compra, entrega real e estimativa logística.
* **Perfil do Cliente (olist_customers_dataset):** Identificação única do cliente e sua localização geográfica detalhada por estado (UF).

## Resultados e Insights de Negócio

### 1. Tempo Médio de Entrega dos Pedidos por Estado (UF)
**Contexto:** Cruzamento de dados de pedidos e clientes para identificar quais estados sofrem mais com a demora logística e entender a disparidade regional na eficiência das transportadoras.
* **Resultado Encontrado:** A análise isolou os tempos de transporte por unidade federativa e revelou uma grande assimetria geográfica. O estado que mais sofre com a demora logística é Roraima (RR), registrando o maior tempo médio do país com 704,7 horas. Em contrapartida, São Paulo (SP) apresentou-se como a operação mais eficiente e veloz, registrando a menor média nacional com apenas 209,8 horas de transporte.

```sql
SELECT 
    cus.customer_state AS estado,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, order_purchase_timestamp, order_delivered_customer_date)),1) AS tempo_medio
FROM olist_customers_dataset cus
JOIN olist_orders_dataset ped ON cus.customer_id = ped.customer_id
WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
GROUP BY estado
ORDER BY tempo_medio ASC;
```

### 2. Taxa de Pedidos Entregues com Atraso
**Contexto:** Mensuração do indicador de qualidade logística (SLA) através da porcentagem de pedidos cuja data real de entrega ultrapassou o prazo estimado repassado ao cliente.
* **Resultado Encontrado:** A análise consolidou um universo total de 96.478 pedidos entregues. Desse montante, observou-se que 7.826 entregas falharam em cumprir o prazo estipulado, resultando em uma taxa geral de atraso de aproximadamente 8,11%. Esse indicador serve de balizador para renegociação de prazos com parceiros logísticos ou revisão das janelas de promessa de entrega no site.

```sql
SELECT 
    COUNT(*) AS `Total de pedidos`,
    SUM(order_estimated_delivery_date < order_delivered_customer_date) AS `Entregas atrasadas`,
    ROUND((SUM(order_estimated_delivery_date < order_delivered_customer_date)*100)/COUNT(*),2) AS `Taxa de atraso`
FROM olist_orders_dataset
WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL;
```

### 3. Evolução de Pedidos Cancelados por Mês (Ano de 2017)
**Contexto:** Monitoramento do volume de desistências e quebras de fluxo comercial ao longo dos meses para identificar anomalias sazonais ou problemas sistêmicos na saúde das operações.
* **Resultado Encontrado:** O volume de cancelamentos apresentou flutuações perceptíveis ao longo de 2017. O mês de novembro destacou-se com o maior pico de quebras operacionais, registrando cerca de 37 pedidos cancelados, seguido de perto pelo mês de março com 33 ocorrências. Em contrapartida, janeiro consolidou-se como o período mais estável e saudável do ano para a operação, registrando o índice mínimo de apenas 3 cancelamentos.

```sql
SELECT 
    MONTH(order_purchase_timestamp) AS MES,
    COUNT(order_status) AS `Cancel/Mes`
FROM olist_orders_dataset
WHERE order_status = "canceled"
    AND YEAR(order_purchase_timestamp) = 2017
GROUP BY mes
ORDER BY mes DESC;
```