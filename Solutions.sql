-- Created columns of revenue before promotion and reveue increment after promotion for easy query
--								REVENUE_BEFORE						REVENUE_INCREMENT

---------------------------------------------------------------------------------------------------


---Q.1 Provide a list of products with base price greater than 500 and promo type 'BOGOF'


SELECT PRODUCT_NAME
FROM DIM_PRODUCTS P
JOIN FACT_EVENTS E ON P.PRODUCT_CODE = E.PRODUCT_CODE
WHERE E.PROMO_TYPE = 'BOGOF'
	AND E.BASE_PRICE > 500
GROUP BY PRODUCT_NAME

---------------------------------------------------------------------------------------------------


---Q.2 City with most number of stores

SELECT CITY,
	COUNT(STORE_ID) STORES
FROM DIM_STORES
GROUP BY CITY
ORDER BY STORES DESC

---------------------------------------------------------------------------------------------------


---Q.3 Calculate total revenue before and after promotion in millions

SELECT C.CAMPAIGN_NAME CAMPAIGN,
	CONCAT(ROUND(SUM(E.BASE_PRICE * E.QUANTITY_SOLD_BEFORE_PROMO) / 1000000,2),' M') 
	TOTAL_REVENUE_BEFORE_PROMO,
	CONCAT(ROUND(SUM(E.BASE_PRICE * E.QUANTITY_SOLD_AFTER_PROMO) / 1000000,2),' M') 
	TOTAL_REVENUE_AFTER_PROMO
FROM DIM_CAMPAIGNS C
JOIN FACT_EVENTS E ON C.CAMPAIGN_ID = E.CAMPAIGN_ID
GROUP BY CAMPAIGN

---------------------------------------------------------------------------------------------------	


---Q.4 Incremental Sold Quantity (ISQ%) for each category during the Diwali campaign with rank order

WITH MY_CTE AS
	(SELECT DP.CATEGORY CATEGORY,
			ROUND(((SUM(QUANTITY_SOLD_AFTER_PROMO - QUANTITY_SOLD_BEFORE_PROMO)) /
										(SELECT SUM(QUANTITY_SOLD_BEFORE_PROMO)
											FROM FACT_EVENTS
											WHERE CAMPAIGN_ID = 'CAMP_DIW_01')) * 100,2) ISU_PERCENT
		FROM FACT_EVENTS E
		JOIN DIM_PRODUCTS DP ON E.PRODUCT_CODE = DP.PRODUCT_CODE
		JOIN DIM_CAMPAIGNS DC ON E.CAMPAIGN_ID = DC.CAMPAIGN_ID
		WHERE DC.CAMPAIGN_ID = 'CAMP_DIW_01'
		GROUP BY CATEGORY)
SELECT CATEGORY,
	ISU_PERCENT,
	RANK() OVER (ORDER BY ISU_PERCENT DESC) AS RANK_ORDER
FROM MY_CTE


---------------------------------------------------------------------------------------------------


---Q.5 Provide list of top5 products, ranked by Incremental Revenue Percentage (IR%) across all 
    -- campaigns. List will include product name, category and IR%.


SELECT P.PRODUCT_NAME PRODUCT,
	P.CATEGORY CATEGORY,
	ROUND(CAST((SUM(REVENUE_INCREMENT) / SUM(REVENUE_BEFORE)) * 100 AS numeric),2) IR_PERCENT
FROM DIM_PRODUCTS P
JOIN FACT_EVENTS E ON P.PRODUCT_CODE = E.PRODUCT_CODE
GROUP BY PRODUCT, CATEGORY
ORDER BY IR_PERCENT DESC
LIMIT 5



------------------------------------ Store Performance Analysis ------------------------------------


---Q.1 Which are the top 10 stores in terms of Incremental revenue (IR) generated from promotions?

SELECT S.STORE_ID,
	CITY,
	SUM(REVENUE_INCREMENT) IR
FROM DIM_STORES S
JOIN FACT_EVENTS E ON E.STORE_ID = S.STORE_ID
GROUP BY S.STORE_ID, CITY
ORDER BY IR DESC
LIMIT 10;



----------------------------------------------------------------------------------------------------


---Q.2 Which are the bottom 10 stores when it comes to incremental Sold Units (ISU) during 
--		promotional period?

SELECT S.STORE_ID,
	CITY,
	SUM(QUANTITY_SOLD_AFTER_PROMO - QUANTITY_SOLD_BEFORE_PROMO) BOTTOM_ISU
FROM DIM_STORES S
JOIN FACT_EVENTS E ON S.STORE_ID = E.STORE_ID
GROUP BY S.STORE_ID, CITY
ORDER BY BOTTOM_ISU
LIMIT 10;



----------------------------------------------------------------------------------------------------


---Q.3 How does the performance of stores vary by city? Are there any common characteristics among
--		the top-performing stores that could be leverage across other stores?

		-- IN TERMS OF REVENUE

SELECT CITY,									
	SUM(REVENUE_INCREMENT) IR
FROM DIM_STORES S
JOIN FACT_EVENTS E ON E.STORE_ID = S.STORE_ID
GROUP BY CITY
ORDER BY IR DESC;

		-- IN TERMS OF QUANTITY

SELECT CITY,
	SUM(QUANTITY_SOLD_AFTER_PROMO - QUANTITY_SOLD_BEFORE_PROMO) ISU
FROM DIM_STORES S
JOIN FACT_EVENTS E ON S.STORE_ID = E.STORE_ID
GROUP BY CITY
ORDER BY ISU DESC;



-------------------------------------- Promotion type Analysis --------------------------------------


---Q.1 What are the top 2 promotion type that resulted in highest IR?

SELECT PROMO_TYPE,
	SUM(REVENUE_INCREMENT) IR
FROM FACT_EVENTS
GROUP BY PROMO_TYPE
ORDER BY IR DESC
LIMIT 2


----------------------------------------------------------------------------------------------------


---Q.2 What are the bottom 2 promotion types in terms of their impact on ISU?

SELECT PROMO_TYPE,
	SUM(REVENUE_INCREMENT) IR
FROM FACT_EVENTS
GROUP BY PROMO_TYPE
ORDER BY IR
LIMIT 2


-----------------------------------------------------------------------------------------------------

---Q.3 Difference between discount based promo vs BOGOF or cashback promotions?

SELECT PROMO_TYPE,					-- IN TERMS OF REVENUE
	SUM(REVENUE_INCREMENT) REV
FROM FACT_EVENTS
GROUP BY PROMO_TYPE
ORDER BY REV DESC

SELECT PROMO_TYPE,					-- IN TERMS OF QUANTITY
	SUM(QUANTITY_SOLD_AFTER_PROMO - QUANTITY_SOLD_BEFORE_PROMO) ISU
FROM FACT_EVENTS
GROUP BY PROMO_TYPE
ORDER BY ISU DESC


-----------------------------------------------------------------------------------------------------

---Q.4 Which promotions strike the best balance b/w ISU and healthy margins?

SELECT PROMO_TYPE,
	SUM(QUANTITY_SOLD_AFTER_PROMO - QUANTITY_SOLD_BEFORE_PROMO) ISU,
	SUM(REVENUE_INCREMENT) REV
FROM FACT_EVENTS
GROUP BY PROMO_TYPE
ORDER BY REV DESC



------------------------------------- Product and Category Analysis ---------------------------------


---Q.1 Which product categories saw the most significant increase in sales from promotions?

SELECT CATEGORY,
	SUM(REVENUE_INCREMENT) INCREASED_SALES
FROM FACT_EVENTS E
JOIN DIM_PRODUCTS P ON E.PRODUCT_CODE = P.PRODUCT_CODE
GROUP BY CATEGORY
ORDER BY INCREASED_SALES DESC


-----------------------------------------------------------------------------------------------------

---Q.2 Are there any specific products that respond exceptionally well or poor to promotions?

SELECT PRODUCT_NAME,
	SUM(QUANTITY_SOLD_AFTER_PROMO - QUANTITY_SOLD_BEFORE_PROMO) ISU,
	SUM(REVENUE_INCREMENT) REV
FROM FACT_EVENTS E
JOIN DIM_PRODUCTS P ON E.PRODUCT_CODE = P.PRODUCT_CODE
GROUP BY PRODUCT_NAME
ORDER BY REV DESC



-----------------------------------------------------------------------------------------------------

---Q.3 What is the correlation between product category and promotion type effectiveness?

SELECT CATEGORY,
	PROMO_TYPE,
	SUM(QUANTITY_SOLD_AFTER_PROMO - QUANTITY_SOLD_BEFORE_PROMO) ISU,
	SUM(REVENUE_INCREMENT) REV
FROM FACT_EVENTS E
JOIN DIM_PRODUCTS P ON E.PRODUCT_CODE = P.PRODUCT_CODE
GROUP BY CATEGORY,
	PROMO_TYPE
ORDER BY REV DESC,
	ISU DESC


-----------------------------------------------------------------------------------------------------






























































