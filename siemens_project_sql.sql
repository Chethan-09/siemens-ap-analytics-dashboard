select * from vendors
select * from invoices

1--total invoices & spend by vendors
 --identify top vendors by invoice count and total spend
SELECT
	V.VENDOR_NAME,
	V.VENDOR_ID,
	COUNT(I.INVOICE_NUMBER) AS TOTAL_INVOICES,
	SUM(I.INVOICE_AMOUNT) AS TOTAL_SPEND
FROM
	INVOICES I
	JOIN VENDORS V ON I.VENDOR_ID = V.VENDOR_ID
GROUP BY
	V.VENDOR_ID
ORDER BY
	TOTAL_SPEND DESC;

2--overdue invoices
 --identify invoices that are past due_date along with invoice amount
SELECT
	V.VENDOR_NAME,
	I.INVOICE_NUMBER,
	I.INVOICE_AMOUNT,
	I.STATUS,
	CURRENT_DATE - DUE_DATE AS DAYS_OVERDUE
FROM
	INVOICES I
	JOIN VENDORS V ON I.VENDOR_ID = V.VENDOR_ID
WHERE
	I.STATUS <> 'Paid'
	AND DUE_DATE < CURRENT_DATE
ORDER BY
	DAYS_OVERDUE DESC;

3 --top 10 vendors by spend
  --identify highest spend vendor
SELECT
	V.VENDOR_NAME,
	V.CATEGORY,
	V.CURRENCY,
	COUNT(I.INVOICE_NUMBER) AS TOTAL_INVOICES,
	SUM(I.INVOICE_AMOUNT) AS TOTAL_AMOUNT
FROM
	INVOICES I
	JOIN VENDORS V ON I.VENDOR_ID = V.VENDOR_ID
GROUP BY
	V.VENDOR_NAME,
	V.VENDOR_ID,
	V.CATEGORY,
	V.CURRENCY
ORDER BY
	TOTAL_AMOUNT DESC;

4 --payment aging bucket
  --identify overdue invoices 
SELECT
	V.VENDOR_NAME,
	I.INVOICE_NUMBER,
	I.INVOICE_AMOUNT,
	I.DUE_DATE,
	I.CURRENCY,
	CURRENT_DATE - I.DUE_DATE AS DAYS_OVERDUE,
	CASE
		WHEN CURRENT_DATE - DUE_DATE BETWEEN 1 AND 30  THEN '1-30 days'
		WHEN CURRENT_DATE - DUE_DATE BETWEEN 31 AND 60  THEN '31-60 days'
		WHEN CURRENT_DATE - DUE_DATE BETWEEN 61 AND 90  THEN '61-90 days'
		WHEN CURRENT_DATE - DUE_DATE > 90 THEN '90+ days'
	END AS AGING_BUCKET
FROM
	INVOICES I
	JOIN VENDORS V ON I.VENDOR_ID = V.VENDOR_ID
WHERE
	I.STATUS <> 'Paid'
	AND DUE_DATE < CURRENT_DATE
	
	
5 --on-time vs late payments
  --measure payment performance against due dates
SELECT
	P.PAYMENT_DATE,
	I.INVOICE_NUMBER,
	I.DUE_DATE,
	P.PAYMENT_DATE - I.DUE_DATE AS DAYS_DIFFERENCE,
	CASE
		WHEN P.PAYMENT_DATE <= I.DUE_DATE THEN 'On time'
		WHEN P.PAYMENT_DATE >= I.DUE_DATE THEN 'Late payment'
	END AS PAYMENT_PERFORMANCE
FROM
	INVOICES I
	JOIN PAYMENTS P ON I.INVOICE_NUMBER = P.INVOICE_NUMBER 
	
6 --Duplicate Invoice Detection
  --Identify invoices submitted more than once
SELECT
	INVOICE_NUMBER,
	COUNT(*) AS APPEARANCE_COUNT
FROM
	INVOICES
GROUP BY
	INVOICE_NUMBER
HAVING
	COUNT(*) > 1

7--identify departments that are slow in processing invoices
SELECT 
    department,
    COUNT(*) AS total_invoices,
    ROUND(AVG(due_date - invoice_date), 1) AS avg_payment_terms_days,
    SUM(CASE WHEN status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count,
    ROUND(
        SUM(CASE WHEN status = 'OVERDUE' THEN 1.0 ELSE 0 END) * 100 / COUNT(*), 2
    ) AS overdue_pct
FROM invoices
GROUP BY department
ORDER BY overdue_pct DESC;

8--credit note analysis by vendor
SELECT 
    department,
    COUNT(*) AS total_invoices,
    ROUND(AVG(due_date - invoice_date), 1) AS avg_payment_terms_days,
    SUM(CASE WHEN status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count,
    ROUND(
        SUM(CASE WHEN status = 'OVERDUE' THEN 1.0 ELSE 0 END) * 100 / COUNT(*), 2
    ) AS overdue_pct
FROM invoices
GROUP BY department
ORDER BY overdue_pct DESC;

9--identity payment method and failure analysis
SELECT 
    payment_method,
    COUNT(*) AS total_payments,
    SUM(CASE WHEN LOWER(payment_status) = 'cleared' THEN 1 ELSE 0 END) AS cleared,
    SUM(CASE WHEN LOWER(payment_status) = 'failed' THEN 1 ELSE 0 END) AS failed,
	SUM(CASE WHEN LOWER(payment_status) = 'processing' THEN 1 ELSE 0 END) AS processing,
    ROUND(
        SUM(CASE WHEN LOWER(payment_status) = 'failed' THEN 1.0 ELSE 0 END) * 100 
        / COUNT(*), 
        2
    ) AS failure_rate_pct,
    SUM(payment_amount) AS total_amount
FROM payments
GROUP BY payment_method
ORDER BY failure_rate_pct DESC;

10--vendor spend vs po approval status
select
v.vendor_name,
v.category,
po.approval_status,
count(*) as total_pos,
sum(po.po_amount) as total_spend,po.currency
from purchase_orders po
join vendors v on po.vendor_id = v.vendor_id
group by v.vendor_name, v.category, po.approval_status,po.currency
order by total_spend desc;







