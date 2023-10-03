#1
#Problem Statement 1: 
#Johansson is trying to prepare a report on patients who have gone through treatments more than once. 
#Help Johansson prepare a report that shows the patients name, the number of treatments they have undergone,
#and their age, Sort the data in a way that the patients who have undergone more treatments appear on top
#datediff(year, p.dob, getdate()) as age
with cte as (
select patientID,count(treatmentID) as t_cnt
from treatment group by patientID
)

select patientID,personName,t_cnt total_noof_treatment,year(curdate())-year(dob) as age,dob
from cte c
left join   patient p using (patientID)
left join person pe on p.patientID=pe.personID order by  t_cnt DESC;
-- #2
-- Problem Statement 2:  
-- Bharat is researching the impact of gender on different diseases, He wants to analyze if a certain 
-- disease is more likely to infect a certain gender or not.Help Bharat analyze this by creating a report 
-- showing for every disease how many males and females underwent treatment for each in the year 2021. 
-- It would also be helpful for Bharat if the male-to-female ratio is also shown.
with cte as (
select diseasename,gender,count(treatmentid) as total_count from disease d
join treatment t using(diseaseid)
left join person   p on t.patientID=p.personID
where year(t.date)='2021' group by diseasename, gender
),
 male as (select diseasename,gender,total_count from cte where gender='Male') ,
 female as(select diseasename,gender,total_count from cte where gender='Female')
#select *from cte join male using(diseasename) join female using(diseasename);
 
select diseasename,cte.gender,cte.total_count,male.total_count/female.total_count as male_to_female_ratio
 from cte join male using(diseasename) join female using(diseasename);
 #3
--  Kelly, from the Fortis Hospital management, has requested a report that shows for each disease, 
--  the top 3 cities that had the most number treatment for that disease.
-- Generate a report for Kelly’s requirement.
with cte as(
select diseasename ,count(treatmentid) as treatment_count,city,
rank() over (partition  by diseasename order by count(treatmentid) desc) as rnk
 from disease d join treatment t using(diseaseid)
join person p on t.patientID=p.personid
join address using(addressid) group by diseasename,city 
 )
 select diseasename,treatment_count,city from cte where rnk in(1,2,3);

#4
-- Problem Statement 4: 
-- Brooke is trying to figure out if patients with a particular disease are preferring some pharmacies
--  over others or not, For this purpose, she has requested a detailed pharmacy report that shows each
--  pharmacy name, and how many prescriptions they have prescribed for each disease in 2021 and 2022, 
--  She expects the number of prescriptions prescribed in 2021 and 2022 be displayed in two separate columns.
-- Write a query for Brooke’s requirement.
with cte as (
select
	s.pharmacyName
	,d.diseaseName,
    count(p.prescriptionID) as prec,
	year(t.date) as yr
from Disease d
join Treatment t on t.diseaseID = d.diseaseID
join Prescription p on p.treatmentID = t.treatmentID
join Pharmacy s on s.pharmacyID = p.pharmacyID
where year(t.date) in (2021, 2022)
group by pharmacyName, d.diseaseName,year(t.date)),
c2021 as (
select pharmacyName,diseaseName,prec as '2021' from cte where yr='2021'
),
c2022 as (
select pharmacyName,diseaseName,prec as '2022' from cte where yr='2022'
)
select * from c2021 full join c2022 using(pharmacyName,diseaseName);
#select pharmacyName,diseaseName,year1 from cte group by 
#5 Problem Statement 5:  
-- Walde, from Rock tower insurance, has sent a requirement for a report that presents which
--  insurance company is targeting the patients of which state the most. Write a query for Walde that
--  fulfills the requirement of Walde.Note: We can assume that the insurance company is targeting
--  a region more if the patients of that region are claiming more insurance of that company.
with cte as
(select
	ic.companyName
	,a.state
	,count(p.patientID) as patient_cnt
	,rank() over(partition by ic.companyName order by count(p.patientID) desc) as rnk
from InsuranceCompany ic
join InsurancePlan ip on ip.companyID = ic.companyID
join Claim c on c.uin = ip.uin
join Treatment t on t.claimID = c.claimID
join Patient p on p.patientID = t.patientID
join Person pn on pn.personID = p.patientID
join Address a on a.addressID = pn.addressID
group by ic.companyName, a.state)
select
	*
from cte
where rnk = 1;


 


