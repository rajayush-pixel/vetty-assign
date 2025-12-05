
-- Q1. This query calculates how many valid purchases were made each month by grouping transactions by year and month while filtering out any purchases that were later refunded.
-- We first convert the purchase date into a "Year-Month" format.
SELECT
    TO_CHAR(purchase_time, 'YYYY-MM') AS month,

    -- Count how many purchases happened in that month.
    COUNT(*) AS purchase_count
FROM transactions

-- We only want to count real purchases. So we exclude any transaction where the item was refunded.
WHERE refund_item IS NULL         
-- group all the filtered transactions by month, so we get a monthly total instead of individual transaction records.
GROUP BY TO_CHAR(purchase_time, 'YYYY-MM')

-- sorting the result so the months appear in order (Jan, Feb, Mar...).
ORDER BY month;



-- Q2.This query filters transactions from October 2020 and counts how many stores achieved 5 or more orders during that month by grouping and applying a threshold condition.


-- Counting how many stores meet the required condition
SELECT COUNT(*) AS num_stores
FROM (

    -- For each store, count how many orders were placed during October 2020
    SELECT store_id,
           COUNT(*) AS order_count
    FROM transactions

    -- Considering only transactions that happened from Oct 1 to Oct 31, 2020
    WHERE purchase_time >= TIMESTAMP '2020-10-01'
      AND purchase_time <  TIMESTAMP '2020-11-01'

    -- Grouping transactions by store to calculate their order volume
    GROUP BY store_id

    -- Only includeing stores that received at least 5 orders in that month
    HAVING COUNT(*) >= 5
) s; 




-- Q3. 


-- This query identifies the minimum time gap between purchase and refund for each store by calculating the time difference (in minutes) only for rows where a refund exists.

-- We want to identify, for each store, how quickly the fastest refund occurred.

SELECT
    store_id,
     MIN(EXTRACT(EPOCH FROM (refund_item - purchase_time)) / 60.0) 
    -- Identifies the store for which we are calculating refund timing

    -- Calculating the time difference between refund and purchase.
    -- EXTRACT(EPOCH FROM ...) returns the difference in seconds.
    -- We divide by 60.0 to convert seconds into minutes.
    -- MIN() is used because we want the shortest (fastest) refund interval for each store.
        AS shortest_interval_min

FROM transactions

-- Only include records where a refund actually took place, because calculating a time difference doesn’t make sense without a valid refund timestamp.
WHERE refund_item IS NOT NULL

-- Grouping the data by store_id so each store receives its own calculated shortest refund time.
GROUP BY store_id;





-- Q4.This query finds the earliest purchase timestamp for each store and returns the corresponding transaction value, representing each store’s first recorded sale.

-- Creating a Common Table Expression (CTE) that identifies the earliest purchase made at each store.
-- MIN(purchase_time) gives us the first recorded purchase timestamp for every store.
WITH first_order AS (
    SELECT
        store_id,                     -- Unique identifier for the store
        MIN(purchase_time) AS first_purchase_time   -- Date and time of the store's first-ever transaction
    FROM transactions
    GROUP BY store_id                 -- Ensures we find the earliest timestamp for each store individually
)

SELECT
    t.store_id,                       -- Store whose first purchase details are being retrieved
    t.gross_transaction_value         -- Transaction value of that very first purchase
FROM transactions t

-- Joining the main table with the CTE so we can match each store
-- to its exact first transaction using both the store ID and the purchase timestamp.
JOIN first_order f
  ON t.store_id = f.store_id
 AND t.purchase_time = f.first_purchase_time;


-- Q5 This query ranks purchases per buyer chronologically, selects only their first transaction, joins to the item details, and determines which item appears most frequently as a first purchase.
-- This Common Table Expression assigns a ranking number to each purchase made by a buyer.
-- ROW_NUMBER() assigns the value 1 to the first item they purchased, based on purchase_time.This helps us isolate the very first item each buyer ever bought.
WITH first_purchase AS (
    SELECT
        buyer_id,              -- Identifies the customer
        item_id,               -- The product they purchased
        ROW_NUMBER() OVER (
            PARTITION BY buyer_id         -- Reset ranking for each individual buyer
            ORDER BY purchase_time        -- The earliest purchase receives rank 1
        ) AS rn
    FROM transactions
),

-- The second CTE retrieves additional details about that first purchased item,
-- We apply the condition fp.rn = 1 to ensure we only keep the very first purchased item per buyer.
first_items AS (
    SELECT
        fp.buyer_id,          -- Buyer associated with that first purchase
        fp.item_id,           -- ID of the first purchased item
        i.item_name           -- Human-readable name of the item for reporting purposes
    FROM first_purchase fp
    JOIN items i
      ON fp.item_id = i.item_id     -- Match the item ID to fetch item information
     AND fp.item_id IS NOT NULL     -- Ensure we ignore missing or invalid item references
    WHERE fp.rn = 1                 -- Keeps only the earliest purchase for each buyer
)

-- Finally, we calculate which item has been the most common "first purchase" across all buyers.
-- The COUNT(*) shows how many buyers purchased that item as their first choice.
SELECT
    item_name,                 -- The name of the product that appeared as a first purchase
    COUNT(*) AS times_ordered  -- How many times that item was the first purchase
FROM first_items
GROUP BY item_name             -- Grouping so we count occurrences per item
ORDER BY times_ordered DESC    -- Sort to list the most commonly chosen first purchase on top
LIMIT 1;                       -- Return only the single highest-ranking item


-- Q6
-- This query checks whether each transaction with a refund request falls within 72 hours of the original purchase and assigns a flag indicating if the refund can be processed.

-- Retrieving transaction-level details to determine whether a refund request
SELECT
    buyer_id,                  
    purchase_time,               
    refund_item,                 
    store_id,                    
    item_id,                    
    gross_transaction_value,     

    -- CASE expression used to evaluate eligibility for refund processing.
    -- The rule here states: If a refund exists AND the refund was requested
    -- within 72 hours from the original purchase time, then the refund is allowed.
    -- Otherwise, the refund cannot be processed.
    CASE
        WHEN refund_item IS NOT NULL                        -
         AND refund_item <= purchase_time + INTERVAL '72 hours'  
        THEN 1     
        ELSE 0     
    END AS can_process_refund  

FROM transactions;




-- Q7


-- This query ranks purchases for each buyer based on purchase time and returns only the row corresponding to their second valid (non-refunded) transaction.

-- Creating a temporary result set that assigns a sequence number to each purchase made by a buyer.
-- ROW_NUMBER() labels each transaction in the order they occurred, based on purchase_time.
WITH ordered AS (
    SELECT
        buyer_id,               
        purchase_time,       
        
        ROW_NUMBER() OVER (
            PARTITION BY buyer_id      
            ORDER BY purchase_time      
        ) AS rn
    FROM transactions
)

-- Retrieving only the second recorded transaction for each buyer.
-- rn = 2 indicates the second time that buyer made a purchase based on timestamp ordering.
SELECT
    buyer_id,                             
    purchase_time AS second_transaction_time  
FROM ordered
WHERE rn = 2;                              -- Filter ensures we only keep the second purchase per buyer



-- Q8


-- This query uses window ranking to identify the second chronological transaction per buyer and returns only the buyer ID and timestamp of that second purchase.

-- This Common Table Expression assigns a running sequence number to each purchase made by a buyer.
-- Using ROW_NUMBER(), we can identify the first, second, third, etc., transactions, by ordering them chronologically for each individual buyer.
WITH ordered AS (
    SELECT
        buyer_id,           
        purchase_time,     

        ROW_NUMBER() OVER (
            PARTITION BY buyer_id       
            ORDER BY purchase_time      
        ) AS rn                         
    FROM transactions
)

-- The final result returns only the second transaction performed by each buyer.
-- We filter where rn = 2, because the row number assigned as 2 represents
-- the buyer's second-ever purchase recorded in the system.
SELECT
    buyer_id,                              
    purchase_time AS second_transaction_time
FROM ordered
WHERE rn = 2;                               -- Ensures only the second chronological purchase per buyer is returned

