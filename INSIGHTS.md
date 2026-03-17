# 📊 Analyst Insights — E-Commerce SQL Analytics

> These findings are drawn from the sample dataset and are intended to demonstrate
> how a business analyst would interpret query results and translate them into
> actionable recommendations for stakeholders.

---

## 1. Revenue is dangerously concentrated in two categories

**Finding:** Laptops ($5,500) and Phones ($4,700) account for **95% of total revenue**.
Books ($210) and Clothing ($390) are effectively negligible contributors.

**So what?**
A business with this revenue profile has no cushion. If Apple releases a competing
product or a supply chain disruption hits laptop inventory, revenue collapses with
no other category to absorb the shock. This is a single-point-of-failure problem,
not a portfolio.

**Recommendation:**
Investigate whether Books and Clothing have low revenue because of low demand,
low pricing, or low visibility. Run a promotion on those categories and measure
conversion lift before writing them off.

---

## 2. Alice J. is a flight risk worth protecting

**Finding:** Alice J. accounts for **$3,035 LTV** — 28% of total revenue from a
single customer. She has placed 3 orders, the most of any customer.

**So what?**
In a real dataset, this level of concentration in one customer is a red flag.
If Alice churns, total revenue drops by more than a quarter. No healthy e-commerce
business should be this dependent on one buyer.

**Recommendation:**
Flag high-LTV customers for a loyalty or retention program. Monitor order frequency
— if Alice's gap between orders widens, trigger a re-engagement campaign before
she goes quiet. Also: find the 2-3 customers who look most like Alice and invest
in moving them up the LTV curve.

---

## 3. The cancellation rate is acceptable but the timing isn't

**Finding:** 1 of 10 orders was cancelled (10%). Industry benchmark for e-commerce
cancellation is typically 5–8%, so 10% is slightly elevated but not alarming.

**However:** Order #006 (Ethan B., $1,499.99 — a Dell XPS 15) was the cancelled
order. That's the highest-value cancellation possible in this dataset.

**So what?**
A $1,500 cancellation on a laptop likely signals a price objection, a competitor
win, or a fulfilment delay. These are fixable problems — but only if you know
which one it is.

**Recommendation:**
Add a `cancellation_reason` field to the orders table. Without it, you're measuring
the symptom (cancellation) but blind to the cause. Segment cancellation rates by
product category — high-ticket electronics likely cancel for different reasons than
apparel.

---

## 4. April's revenue spike needs an explanation before it becomes a forecast input

**Finding:** April revenue ($4,330) was **2.1x higher than any other month**.
Jan–Mar averaged ~$2,053/month. May dropped back to $1,030 — the lowest month.

**So what?**
This pattern could mean several things: a one-time bulk order, a promotional event,
a seasonal effect, or simply noise from a small dataset. The danger is treating
April as representative when building forecasts — it will inflate projections and
set targets the business can't hit.

**Recommendation:**
Before using this data for forecasting, tag orders with an acquisition source
(organic, promo, referral). April's spike is only useful if you know whether it's
repeatable. A rolling 3-month average (already built in `04_orders.sql`) is a
more reliable baseline than point-in-time monthly figures at this data volume.

---

## 5. Product ratings don't yet tell the full story — but the gaps are telling

**Finding:** Only 6 of 13 order line items resulted in a review (46% review rate).
The MacBook Pro has a perfect 5.0 from 1 review. Women's Sneakers have a 3.0.

**So what?**
A 3.0 on a $90 product with no follow-up is a quiet churn signal. Customers who
leave 3-star reviews rarely come back. Meanwhile, a 5.0 from a single review on
a $2,000 laptop is statistically meaningless — one unhappy customer away from a
damaging rating drop.

**Recommendation:**
Weight review scores by volume before acting on them. A product with a 4.8 from
50 reviews is far more signal than a 5.0 from 1. Also: target the 54% of buyers
who didn't leave reviews — a post-purchase email sequence would meaningfully
improve both review volume and the reliability of your ratings data.

---

## 6. The schema is built for today, not for scale

**Finding (structural):** The current schema has no `promotions` table, no
`sessions` or `events` table, no `returns` table, and no `payment_status` field
on orders. The `cancellation_reason` is also absent (see Finding 3).

**So what?**
These aren't missing because the data doesn't exist — they're missing because
the schema wasn't designed with analytical depth in mind. As a result, several
high-value analyses are impossible with the current structure:

- You cannot calculate **marketing attribution** (which channel drove each order)
- You cannot calculate **true net revenue** (gross minus returns/refunds)
- You cannot build a **conversion funnel** (sessions → PDPs → cart → checkout → order)
- You cannot measure **promotional ROI** (did the discount pay for itself?)

**Recommendation:**
For a v2 schema, add: `sessions`, `returns`, `promotions`, `order_promotions`
(junction table), and `payment_transactions`. These six tables unlock the analyses
that actually drive business decisions.

---

*Prepared as part of the [E-Commerce SQL Analytics](https://github.com/tarang-tj/ecommerce-sql) project.*
*All figures reference the included seed dataset (`data/seed.sql`).*
