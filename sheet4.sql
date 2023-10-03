-- #1
-- HealthDirect” pharmacy finds it difficult to deal with the product type of medicine being displayed in 
-- numerical form, they want the product type in words. Also, they want to filter the medicines based on tax criteria. 
-- Display only the medicines of product categories 1, 2, and 3 for medicines that come under tax category I 
-- and medicines of product categories 4, 5, and 6 for medicines that come under tax category II.
-- Write a SQL query to solve this problem.
-- ProductType numerical form and ProductType in words are given by
select productname,producttype,taxCriteria,
case producttype
  when 1 then 'Generic'
  when 2 then 'Patent'
when 3 then 'Reference'
		when 4 then 'Similar'
		when 5 then 'New'
		when 6 then 'Specific'
		when 7 then 'Biological'
		when 8 then 'Dinamized'
		else 'Unknown'
	END as productCategory
    from medicine
    where taxCriteria='I' and producttype in(1,2,3) or 
    taxCriteria='II' and producttype in(4,5,6);
    
    
    # 2
    select 
	p.prescriptionID
	,sum(c.quantity) as med_cnt
	,case 
		when sum(c.quantity) < 3 then 'low'
		when sum(c.quantity) < 5 then 'medium'
		else 'high'
	end as category
from Prescription p 
join Contain c on c.prescriptionID = p.prescriptionID
group by p.prescriptionID;
#3
-- In the Inventory of a pharmacy 'Spot Rx' the quantity of medicine is considered ‘HIGH QUANTITY’ 
-- when the quantity exceeds 7500 and ‘LOW QUANTITY’ when the quantity falls short of 1000. The discount
--  is considered “HIGH” if the discount rate on a product is 30% or higher, and the discount is
--  considered “NONE” when the discount rate on a product is 0%.
with cte as (
select pharmacyName,productName,quantity,
case 
when quantity>7500 then 'HIGH QUANTITY' 
when quantity<7500 and quantity>1000 then 'MED QUANTITY'
else 'LOW QUANTITY' 
end as  quantity_category ,
discount ,
case 
when discount>=30 then 'HIGH' 
when discount<30 and discount>0  then 'MED' 
else 'none ' 
end as  discount_category 
from medicine m
join keep k using(medicineID)
join pharmacy p using (pharmacyID)
where pharmacyName = 'Spot Rx')
select * from cte;


-- Problem 4
with cte as
(select 
	productName
	,maxPrice
	, case
		when maxPrice < 0.5 * avg(maxPrice) over() then 'low'
		when maxPrice > 2 * avg(maxPrice) over() then 'high'
		else NULL
	end as cat
from Medicine)
select 
	productName
	,maxPrice
	,cat
from cte
where cat is not Null
;

-- Problem 5
select
	p.personName
	,p.gender
	,pt.dob
	,  CASE
		WHEN pt.dob >= '2005-01-01' AND gender = 'Male' THEN 'YoungMale'
		WHEN pt.dob >= '2005-01-01' AND gender = 'Female' THEN 'YoungFemale'
		WHEN pt.dob < '2005-01-01' AND pt.dob >= '1985-01-01' AND gender = 'Male' THEN 'AdultMale'
		WHEN pt.dob < '2005-01-01' AND pt.dob >= '1985-01-01' AND gender = 'Female' THEN 'AdultFemale'
		WHEN pt.dob < '1985-01-01' AND pt.dob >= '1970-01-01' AND gender = 'Male' THEN 'MidAgeMale'
		WHEN pt.dob < '1985-01-01' AND pt.dob >= '1970-01-01' AND gender = 'Female' THEN 'MidAgeFemale'
		WHEN pt.dob < '1970-01-01' AND gender = 'Male' THEN 'ElderMale'
		WHEN pt.dob < '1970-01-01' AND gender = 'Female' THEN 'ElderFemale'
		ELSE 'Unknown'
	END

from Patient pt
join Person p on p.personID = pt.patientID;

