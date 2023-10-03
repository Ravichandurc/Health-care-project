#1
-- : A company needs to set up 3 new pharmacies, they have come up with an idea that the
--  pharmacy can be set up in cities where the pharmacy-to-prescription ratio is the lowest
--  and the number of prescriptions should exceed 100. 
-- Assist the company to identify those cities where the pharmacy can be set up.
select city,count(DISTINCT pharmacyID),count(DISTINCT prescriptionID) as total_prescription,
count(DISTINCT pharmacyID)/count(DISTINCT prescriptionID) as pharmacy_to_prescription  from
address
 inner join pharmacy ph using (addressID)
inner join prescription pe using (pharmacyID)
group by city HAVING count(DISTINCT prescriptionID) > 100 
order by  count(DISTINCT pharmacyID)/count(DISTINCT prescriptionID) desc limit 3 ;
# 2
-- The State of Alabama (AL) is trying to manage its healthcare resources more efficiently.
--  For each city in their state, they need to identify the disease for which the maximum number of 
--  patients have gone for treatment. Assist the state for this purpose.
-- Note: The state of Alabama is represented as AL in Address Table.
-- with cte as(
-- select city,diseasename,count(diseasename) as no_of_disease
-- #ROW_NUMBER() OVER (PARTITION BY diseasename ORDER BY count(diseasename) DESC) AS rn 
-- from address a
-- left join pharmacy ph using (addressID)
-- left join prescription pe using(pharmacyID)
-- left join treatment t using ( treatmentID)
-- left join  disease d using (diseaseID)
-- where state='AL' group by city,diseasename )
-- select * from cte; count(p.patientID)

with cte as
(select 
	a.city
	,d.diseaseName
	-- ,pn.personID
	,count(p.patientID) as dis_cnt
	,rank() over(partition by a.city order by count(p.patientID) desc) as rnk
from Disease d 
join Treatment t on t.diseaseID = d.diseaseID
join Patient p on p.patientID = t.patientID
join Person pn on pn.personID = p.patientID
join Address a on a.addressID = pn.addressID
where a.state = 'AL'
group by a.city, d.diseaseName)
select 
	city
	,diseaseName
	,dis_cnt
from cte
where rnk = 1
;
# Problem Statement 3: The healthcare department needs a report about insurance plans.
--  The report is required to include the insurance plan, which was claimed the most and 
--  least for each disease. Assist to create such a report.
with cte as(
select diseaseName,count(claimID),planName 
,ROW_NUMBER() over(partition by diseaseName order by count(claimID) desc) as max_rank
,ROW_NUMBER() over(partition by diseaseName order by count(claimID) ) as min_rank
from disease 
join treatment using (diseaseID)
join claim using (claimID)
join insuranceplan using (UIN) 
group by diseaseName,planName )
select diseaseName,c1.planName as max_plan,c2.planName as min_plan  from cte c1 join cte c2
using (diseaseName)
 where c1.max_rank=1 and c2.min_rank=1 ;
 #4
 -- Problem Statement 4: The Healthcare department wants to know which disease is most likely 
--  to infect multiple people in the same household. For each disease find the number of 
--  households that has more than one patient with the same disease. 
-- Note: 2 people are considered to be in the same household if they have the same address.

 with cte as
(select 
	d.diseaseName
	,a.address1
	,count(p.patientID) as total
from Disease d 
join Treatment t on t.diseaseID = d.diseaseID
join Patient p on p.patientID = t.patientID
join Person pn on pn.personID = p.patientID
join Address a on a.addressID = pn.addressID
group by d.diseaseName ,a.addressID
having count(p.patientID) > 1)
select 
	diseaseName
	,COUNT(address1) as total_count
from cte
group by diseaseName
order by total_count desc;
 # 5
 -- Problem Statement 5:  An Insurance company wants a state wise report of the treatments to
--  claim ratio between 1st April 2021 and 31st March 2022 (days both included). Assist them 
--  to create such a report.
with cte as(
select a.state,count(c.claimID) as  claim_count,count(t.treatmentid) as treatment_count from treatment t
left join  claim c using (claimID)
-- join patient pa using (patientid)
join person pe on t.patientid=pe.personid
join address a using(addressid)
where t.date between '2021-04-01' and '2022-03-31'
 group by a.state   )
 select state,treatment_count,claim_count,treatment_count / claim_count AS treatment_to_claim_ratio from cte;


