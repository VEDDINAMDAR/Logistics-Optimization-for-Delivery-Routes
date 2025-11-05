Create database Logistics;
use Logistics;

-- Task 1-- 

Select order_id, count(order_id) as count
from orders
group by order_id
Having count(order_id) > 1;

Select *
from routes
where Traffic_Delay_Min is Null;

Alter Table Orders
Modify column order_date Date;

Alter Table Orders
Modify column Expected_Delivery_Date Date;

Alter Table Orders
Modify column Actual_Delivery_Date Date;

Select *
from orders
where Actual_Delivery_Date < order_date;

-- Task 2-- 

Select *, datediff(Actual_Delivery_Date, Expected_Delivery_Date) as delay
from orders;

Select Route_id, avg(datediff(Actual_Delivery_Date, Expected_Delivery_Date)) as avg_delay
from orders
group by route_id
order by avg_delay desc
Limit 10;

select *, rank() over (partition by Warehouse_Id order by datediff(Actual_Delivery_Date, Expected_Delivery_Date) desc) as ranks
from orders
order by ranks desc;

-- Task 3--


Select r.Route_Id, avg(datediff(o.Actual_Delivery_Date, o.Order_date)) as avg_delivery_time, (r.Distance_KM / r.Average_Travel_Time_Min) as Effeciency_ratio,Avg(r.Traffic_delay_min) avg_traffic_delay
from orders o join routes r
on o.route_id = r.route_id
group by route_id, r.Distance_KM, r.Average_Travel_Time_Min 
order by Route_id;

Select route_id, (Distance_KM / Average_Travel_Time_Min) as effeciency_ratio
from routes
order by effeciency_ratio
limit 3;

Select route_id, 
sum(case when Delivery_Status = 'Delayed' Then 1 Else 0 End) As delyed_shipments
from orders;

SELECT 
    Route_ID,
    COUNT(*) AS TotalShipments,
    SUM(CASE WHEN Delivery_Status = 'Delayed' THEN 1 ELSE 0 END) AS DelayedShipments,
    (SUM(CASE WHEN Delivery_Status = 'Delayed' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS DelayPercentage
FROM Orders
GROUP BY Route_ID
HAVING DelayPercentage >= 20
order by Route_id;

-- Task 4--

Select warehouse_id, avg(processing_time_min) as avg_processing_time
from warehouses
group by warehouse_id
order by avg_processing_time desc
limit 3;

Select warehouse_id, count(*) as total_shipment, sum(case when Delivery_Status = 'Delayed' Then 1 Else 0 End) As delyed_shipments
from orders
group by warehouse_id
order by warehouse_id;

WITH Processing_time AS (
    SELECT 
        warehouse_id,
        AVG(DATEDIFF(actual_delivery_date, order_date)) AS avg_processing_time
    FROM orders
    GROUP BY warehouse_id
),
Global_Processing_time AS (
    SELECT 
        AVG(avg_processing_time) AS global_avg
    FROM Processing_time
)
SELECT 
    P.warehouse_id,
    P.avg_processing_time,
    G.global_avg
FROM Processing_time P
CROSS JOIN Global_Processing_time G
WHERE P.avg_processing_time > G.global_avg;

Select warehouse_id,Rank() over (order by on_time_delivery_Percentage desc) as 'Rank',on_time_delivery_Percentage
from(
Select warehouse_id, ((sum(case when Delivery_status = 'On Time' then 1 else 0 End))/ count(*) ) *100 as on_time_delivery_Percentage
from orders
Group by warehouse_id) As ware_house;

-- Task 5--

Select Route_id, Agent_id, Rank() over (Partition by Route_id order by On_Time_Percentage desc) As 'Rank',On_Time_Percentage
from deliveryagents; 

Select Agent_id, On_Time_Percentage
from deliveryagents
where On_Time_Percentage > 80;

Select avg(t.avg_speed) as top5, avg(b.avg_speed) as bot5
from(
Select d.agent_id, d.Avg_Speed_KM_HR as avg_speed
from deliveryagents d
order by On_Time_Percentage desc
Limit 5) t 
cross join (
Select d.agent_id, d.Avg_Speed_KM_HR as avg_speed
from deliveryagents d
order by On_Time_Percentage asc
Limit 5) b;

-- Task 6--

Select O.Order_id,O.checkpoint 
from (Select order_id, checkpoint, rank() over (partition by order_id order by Checkpoint_Time desc) as rnk
	  from shipment) O
where rnk = 1;

Select Delay_reason, count(*) as No_of_times_used
from shipment
group by Delay_reason
order by No_of_times_used desc;

Select Order_id, Count(*) as delaycheckpoints
from shipment
Where Delay_Reason IS NOT NULL
Group by order_id
Having count(*)>2
order by delaycheckpoints desc;

-- Task 7-- 

SELECT 
    R.Start_Location,
    (SUM(CASE WHEN O.Delivery_Status = 'Delayed' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS Delayed_Percentage
FROM Orders O
LEFT JOIN Routes R 
    ON O.Route_ID = R.Route_ID
GROUP BY R.Start_Location
order by delayed_percentage desc;

Select (sum(case when Delivery_status = 'On Time' then 1 else 0 end) / Count(*)) * 100 AS On_Time_Delivery
From Orders;










        

