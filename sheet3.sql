-- Problem Statement 1:  Some complaints have been lodged by patients that they have been prescribed 
-- hospital-exclusive medicine that they can’t find elsewhere and facing problems due to that. Joshua,
--  from the pharmacy management, wants to get a report of which pharmacies have prescribed 
#hospital-exclusive
--  medicines the most in the years 2021 and 2022. Assist Joshua to generate the report so that the pharmacies
--  who prescribe hospital-exclusive medicine more often are advised to avoid such practice if possible.
select pharmacyID,pharmacyName,count(year(t.date)) as frequency  from pharmacy ph
join prescription  pr using (pharmacyID)
join treatment t using(treatmentID)
join contain c using(prescriptionID)
join medicine m using(medicineID)
where t.date between  '2021-01-01' and '2022-12-30'
and m.hospitalExclusive='S' group by pharmacyID,pharmacyName order by frequency desc
;

-- Problem Statement 2: Insurance companies want to assess the performance of their insurance plans.
--  Generate a report that shows each insurance plan, the company that issues the plan, and the number of 
--  treatments the plan was claimed for.
select companyname,planname,count(treatmentID) as no_of_treatment from insurancecompany
join insuranceplan using (companyID)
join claim using (UIN)
left join   treatment using (claimID) group by companyname,planname ;

-- Problem Statement 3: Insurance companies want to assess the performance of their insurance plans. 
-- Generate a report that shows each insurance company's name with their most and least claimed insurance plans.


with cte as(
select companyname,count(claimID),planName 
,ROW_NUMBER() over(partition by companyname order by count(claimID) desc) as max_rank
,ROW_NUMBER() over(partition by companyname order by count(claimID) ) as min_rank
from insurancecompany 
join insuranceplan using (companyID)
join claim using (UIN)
join treatment using (claimID) 
group by companyname,planName )
select companyname,c1.planName as max_plan,c2.planName as min_plan  from cte c1 join cte c2
using (companyname)
 where c1.max_rank=1 and c2.min_rank=1 ;
 
 
-- Problem Statement 4:  The healthcare department wants a state-wise health report to assess which 
--  state requires more attention in the healthcare sector. Generate a report for them that shows the
--  state name, number of registered people in the state, number of registered patients in the state,
--  and the people-to-patient ratio. sort the data by people-to-patient ratio.

 select state,count(personID) as no_of_persons,count(patientID)as no_of_patient,
 count(personID)/count(patientID) as people_to_patient_ratio  from person pe
 left join patient pa on pe.personID=pa.patientID
 join address using(addressid) group by state order by people_to_patient_ratio ;
 
 
 #5
 -- Problem Statement 5:  Jhonny, from the finance department of Arizona(AZ), has requested a report that
--  lists the total quantity of medicine each pharmacy in his state has prescribed that falls under
--  Tax criteria I for treatments that took place in 2021. Assist Jhonny in generating the report. 

select 
	s.pharmacyName
	,sum(c.quantity) as med_cnt
from Medicine m
join Contain c on c.medicineID = m.medicineID
join Prescription p on p.prescriptionID = c.prescriptionID
join Pharmacy s on s.pharmacyID = p.pharmacyID
join Address a on a.addressID = s.addressID
join Treatment t on t.treatmentID = p.treatmentID
where m.taxCriteria = 'I'
and year(t.date) = 2021
and a.state = 'AZ'
group by s.pharmacyName;



 
