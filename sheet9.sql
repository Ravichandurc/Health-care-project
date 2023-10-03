/* Problem Statement 1: 
Brian, the healthcare department, has requested for a report 
that shows for each state how many people underwent treatment for the disease “Autism”.  
He expects the report to show the data for each state 
as well as each gender and for each state and gender combination. 
Prepare a report for Brian for his requirement.
*/

select coalesce(State, 'Total') as 'State', coalesce(gender, 'Total') as 'Gender', count(patientID) as 'Patient_Count'
from disease 
join treatment using(diseaseID)
join person on person.personID = treatment.patientID
join address using(addressID)
where diseaseName = 'Autism'
group by state, gender with rollup;



/* Problem Statement 2:  
Insurance companies want to evaluate the performance of different insurance plans they offer. 
Generate a report that shows each insurance plan, the company that issues the plan, 
and the number of treatments the plan was claimed for. 
The report would be more relevant if the data compares the performance for different years(2020, 2021 and 2022) 
and if the report also includes the total number of claims in the different years, 
as well as the total number of claims for each plan in all 3 years combined.
*/

-- set @@sql_mode =  REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY','');


select ip.planname, ic.companyname, 
SUM(IF(YEAR(t.date) = 2020, 1, 0)) AS '2020_Count',
SUM(IF(YEAR(t.date) = 2021, 1, 0)) AS '2021_Count',
SUM(IF(YEAR(t.date) = 2022, 1, 0)) AS '2022_Count',
(SUM(IF(YEAR(t.date) = 2021, 1, 0))+SUM(IF(YEAR(t.date) = 2020, 1, 0))+SUM(IF(YEAR(t.date) = 2022, 1, 0))) as combined 
from insurancecompany ic
join insuranceplan ip using(companyid)
join claim c using(uin)
join treatment t using(claimid)
group by ip.planname, ic.companyname;


/* Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand 
if some diseases are spreading in a particular region.
Assist Sarah by creating a report which shows each state 
the number of the most and least treated diseases 
by the patients of that state in the year 2022. 
It would be helpful for Sarah if the aggregation for the different combinations is found as well. 
Assist Sarah to create this report. 
*/
with cte1 as (
select state, diseaseID,
count(treatmentID) as cnt
from treatment
left join person
on treatment.patientID=person.personID
left join address using (addressID)
left join disease using (diseaseID)
where year(date)='2022'
group by state, diseaseID with rollup
), cte2 as (
select coalesce(cte1.state, 'All States') as states, coalesce(cte1.diseaseID, 'All Diseases') as diseases, cnt,
row_number() over(partition by state order by cnt desc) as max_cnt_rnk,
row_number() over(partition by state order by cnt asc) as min_cnt_rnk
from cte1
)
select states, diseases, cnt
from cte2
where max_cnt_rnk in (1,2) or min_cnt_rnk=1
; 



/* Problem Statement 4: 
Jackson has requested a detailed pharmacy report that shows each pharmacy name, 
and how many prescriptions they have prescribed for each disease in the year 2022, 
along with this Jackson also needs to view how many prescriptions were prescribed by each pharmacy, 
and the total number prescriptions were prescribed for each disease.
Assist Jackson to create this report. 
*/

select pharmacyName, coalesce(DiseaseName, 'Total'), count(prescriptionID) as 'Prescription_Count'
from Pharmacy
join Prescription using(pharmacyID)
join treatment using(treatmentID)
join disease using(diseaseID)
where year(date) = 2022
group by pharmacyName, DiseaseName with rollup
order by pharmacyName, Prescription_Count desc;

/* Problem Statement 5:  
Praveen has requested for a report that finds for every disease how many 
males and females underwent treatment for each in the year 2022. 
It would be helpful for Praveen if the aggregation for the different combinations is found as well.
Assist Praveen to create this report. 
*/
select  diseaseName, coalesce(gender, 'Total') as 'Gender', count(patientID) as 'Patient_Count'
from disease
join treatment using(diseaseID)
join person on person.personiD= treatment.patientID
group by diseaseName, gender with rollup;
