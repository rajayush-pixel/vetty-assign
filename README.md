# 📌 SQL Assignment – E-Commerce Transactions Analysis

This repository contains SQL solutions based on a sample dataset of store transactions and item catalog data.  
The project demonstrates SQL querying, analytics, date-time functions, filtering, window functions, and reporting.

---

## 📁 Dataset Overview

The assignment uses **two tables:**

### 🧾 `transactions`

| Column Name | Description |
|------------|-------------|
| buyer_id | Unique identifier for the customer |
| purchase_time | Timestamp of the transaction |
| refund_item | Timestamp when refund was requested (NULL if no refund) |
| store_id | Store where the item was purchased |
| item_id | Reference to the item purchased |
| gross_transaction_value | Total sale amount |

---

### 🛍️ `items`

| Column Name | Description |
|------------|-------------|
| store_id | Store that owns the item |
| item_id | Unique identifier for the item |
| item_category | Type/category of item |
| item_name | Product name |

---

## 🧠 Task Summary

The SQL assignment includes the following objectives:

1. Count purchases per month (excluding refunded purchases)  
2. Identify stores with at least **5** orders in **October 2020**  
3. Calculate the shortest refund time per store  
4. Find the transaction value of each store’s first order  
5. Determine the most frequently purchased item in a buyer’s first order  
6. Create refund eligibility logic (refund allowed only within 72 hours)  
7. Rank purchases per buyer and extract the second purchase  
8. Extract the second transaction date per buyer using window functions (without MIN/MAX)

---

## 🚀 Technologies Used

- SQL (SQLite syntax for execution)
- Window functions
- Date and time manipulation
- Git & GitHub for version tracking

---

## 📷 Execution Screenshots

Screenshots of executed queries and outputs are included for verification.

---

## 📂 Files Included

| File | Description |
|------|-------------|
| `queries.sql` | Contains all final SQL answers |
| `dataset.sql` | Table creation + insert data script |
| `screenshots/` | Query execution proofs |

---

## 🧑‍💻 Author

**Ayush Raj**  
📍 BIT Mesra  
🎓 Data • Analytics • SQL • Databases  

---

## ⭐ Feedback & Contribution

This is an academic exercise — however, suggestions or improvements are welcome.  
Feel free to open an **issue** or submit a **pull request**.

---

### 🔗 Connect on GitHub:  
👉 *Star the repo if you found it useful!*  
