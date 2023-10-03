#6
#1
-- Problem Statement 1: 
-- The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine
--  prescribed in the year 2022.Assist the healthcare department to view for each pharmacy, the pharmacy id, 
--  pharmacy name, total quantity of medicine prescribed in 2022, total quantity of hospital-exclusive medicine
--  prescribed by the pharmacy in 2022, and the percentage of hospital-exclusive medicine to the total medicine
--  prescribed in 2022.Order the result in descending order of the percentage found
select pharmacyid,pharmacyname,sum(c.quantity) as total
,sum( if(m.hospitalExclusive = 'S', c.quantity, 0) ) as hosp_exc_cnt ,
sum( if(m.hospitalExclusive = 'S', c.quantity, 0) ) * 100.0 / sum(c.quantity) as med_exc_norm_ration

from pharmacy
join prescription using(pharmacyid)
join treatment using(treatmentid)
join contain c using(prescriptionid) 
join medicine m using (medicineid)
where year(date)='2022'
group by pharmacyid,pharmacyname order by med_exc_norm_ration desc  ;
#2;
-- Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment.
--  She has requested a state-wise report of the percentage of treatments that took place without claiming 
--  insurance. Assist Sarah by creating a report as per her requirement.

select
	a.state
	,count(c.claimID) as claim_cnt
	,count(t.treatmentID) as treat_cnt
    ,((count(t.treatmentID)-count(c.claimID))*100/(count(t.treatmentID))) as claim_per_total
from Treatment t
join Patient p on p.patientID = t.patientID
join Person pers on pers.personID = p.patientID
left join Claim c on c.claimID = t.claimID
join Address a on a.addressID = pers.addressID
group by a.state;
#3
-- Problem Statement 3:  
-- Sarah, from the healthcare department, is trying to understand if some diseases are spreading in 
-- a particular region. Assist Sarah by creating a report which shows for each state, the number of 
-- the most and least treated diseases by the patients of that state in the year 2022. 
with cte as(

select state,diseasename,count(patientid) as total,
row_number() over (partition  by state order by count(patientid) desc ) as max,
row_number() over (partition  by state order by count(patientid) ) as min
 from 
disease  d
join treatment t  using (diseaseID)
join  person p on  t.patientID=p.personID
join address a using(addressid) where year(t.date) = 2022 group by state,diseasename )
select state,c1.diseasename,c2.diseasename from cte c1 join cte c2
using (state) where c1.max=1 and c2.min=1;

#4 
-- Problem Statement 4: 
-- Manish, from the healthcare department, wants to know how many registered people are registered as patients
--  as well, in each city. Generate a report that shows each city that has 10 or more registered people
--  belonging to it and the number of patients from that city as well as the percentage of the patient 
--  with respect to the registered people.
select city,count(personID) as reg_person,count(patientID)as  reg_patient,
count(patientID) * 100.0 / count(personID) as pat_per_ration
 from address
join person p using(addressid)
left join patient pa on p.personID=pa.patientID
group by city having count(personID)>10 ;
# 5
-- It is suspected by healthcare research department that the substance “ranitidine” might be causing
--  some side effects. Find the top 3 companies using the substance in their medicine so that they can be
--  informed about it.
select p.pharmacyName ,sum(k.quantity) as med_cnt
from Medicine m
join Keep k on k.medicineID = m.medicineID
join Pharmacy p on p.pharmacyID = k.pharmacyID
where m.substanceName like '%ranitidin%'
group by p.pharmacyName
order by med_cnt desc
limit 3;

