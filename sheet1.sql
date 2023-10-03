-- Jimmy, from the healthcare department, has requested a report that shows how the
--  number of treatments each age category of patients has gone through in the year 2022. 
-- The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), 
-- and Seniors (65 years and over).
-- Assist Jimmy in generating the report. 
with cte as (select patientid,year(curdate())-year(p.dob) as age ,
case
when year(curdate())-year(p.dob) < 15 then 'Children'
when year(curdate())-year(p.dob)  between 15 and 24  then 'Youth'
when year(curdate())-year(p.dob)  between 25 and 64  then 'Adults'
else 'Seniors'
end as age_category
 from treatment t 
join patient p
using (patientid)
)
select age_category,count(t.patientid) as patient_count
 from cte c
join treatment t
using( patientid)
where year(t.date)=2022  group by age_category  ;
-- 2.Jimmy, from the healthcare department, wants to know which disease is
--  infecting people of which gender more often.
-- Assist Jimmy with this purpose by generating a report 
-- that shows for each disease the male-to-female ratio. 
-- Sort the data in a way that is helpful for Jimmy.
with male as(
select count(gender) as  total_male,diseaseid,d.diseaseName from treatment t
join  disease d using (diseaseid)
-- join patient pa using (patientid)
join person pe on t.patientid=pe.personid
where gender like '%Male%' group by diseaseid,diseaseName  order by diseaseid ),
female as(select count(gender) as  total_female,diseaseid,d.diseaseName from treatment t
join  disease d using (diseaseid)
-- join patient pa using (patientid)
join person pe on t.patientid=pe.personid
where gender like '%Female%' group by diseaseid,diseaseName  order by diseaseid 
)
select diseaseid,m.diseaseName,m.total_male,f.total_female,
m.total_male / f.total_female AS male_to_female_ratio from male m
join female f using(diseaseid)
;

#3
-- Jacob, from insurance management, has noticed that insurance claims are 
-- not made for all the treatments. He also wants to figure out if the gender 
-- of the patient has any impact on the insurance claim. Assist Jacob in this 
-- situation by generating a report that finds for each gender the number of 
-- treatments, number of claims, and treatment-to-claim ratio. And notice if 
-- there is a significant difference between the treatment-to-claim ratio of male and female patients.
with cte as(
select pe.gender,count(c.claimID) as  claim_count,count(t.treatmentid) as treatment_count from treatment t
left join  claim c using (claimID)
-- join patient pa using (patientid)
join person pe on t.patientid=pe.personid
 group by pe.gender   )
 select gender,treatment_count,claim_count,treatment_count / claim_count AS treatment_to_claim_ratio from cte;
 #4.
-- The Healthcare department wants a report about the inventory of pharmacies. 
-- Generate a report on their behalf that shows how many units of medicine each pharmacy has 
-- in their inventory, the total maximum retail price of those medicines, and the total price 
-- of all the medicines after discount. 
-- Note: discount field in keep signifies the percentage of discount on the maximum price.
select k.pharmacyID,sum(k.quantity) as Medicines,
sum(m.maxPrice*k.quantity) as MaxPrice, 
#MRP - (Discount Percentage/100) * MRP
#(m.maxPrice * k.quantity) * (1 - k.discount / 100)
sum((m.maxPrice*k.quantity)-(k.discount/100)*(m.maxPrice*k.quantity)) as DiscountPrice
from keep k
left join medicine m using (medicineID)
group by k.pharmacyID;
#5
-- The healthcare department suspects that some pharmacies prescribe more medicines 
-- than others in a single prescription, for them, generate a report that finds for each 
-- pharmacy the maximum, minimum and average number of medicines prescribed in their prescriptions. 
with cte as (select pharmacyID,prescriptionID,sum(quantity) as medicine_quantity
from prescription p 
left join contain using (prescriptionID) group by pharmacyID,prescriptionID)
select pharmacyid, max(medicine_quantity) as Maximum, min(medicine_quantity) as Minimum, avg(medicine_quantity) as Average
from cte group by pharmacyId;



