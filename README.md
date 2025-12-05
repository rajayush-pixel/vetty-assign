1. What is the count of purchases per month (excluding refunded purchases)?
2. How many stores receive at least 5 orders/transactions in October 2020?
3. For each store, what is the shortest interval (in min) from purchase to refund time?
4. What is the gross_transaction_value of every store’s first order?
5. What is the most popular item name that buyers order on their first purchase?
6. Create a flag in the transaction items table indicating whether the refund can be processed or
not. The condition for a refund to be processed is that it has to happen within 72 of Purchase
time.
Expected Output: Only 1 of the three refunds would be processed in this case
7. Create a rank by buyer_id column in the transaction items table and filter for only the second
purchase per buyer. (Ignore refunds here)
Expected Output: Only the second purchase of buyer_id 3 should the output
8. How will you find the second transaction time per buyer (don’t use min/max; assume there
were more transactions per buyer in the table)
Expected Output: Only the second purchase of buyer_id along with a timestamp
