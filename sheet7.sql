#7 
-- Insurance companies want to know if a disease is claimed higher or lower than average.
--   Write a stored procedure that returns “claimed higher than average” or “claimed lower than average” 
-- when the diseaseID is passed to it. Hint: Find average number of insurance claims for all the diseases.  
-- If the number of claims for the passed disease is higher than the average return “claimed higher than
--  average” otherwise “claimed lower than average”.
drop procedure if exists avg_disease_claimed;
delimiter //

create procedure avg_disease_claimed(in did int)
begin
declare avg_claim int; 
select round(count(claimid)/count(distinct diseaseid)) into avg_claim  from treatment;

select diseaseid, if(count(claimid)>avg_claim,'Claimed Higher Than Average','Claimed lower Than Average') as status from treatment
where diseaseid=did
group by diseaseid; 
end//

delimiter ;
call avg_disease_claimed(15);

#2
-- Joseph from Healthcare department has requested for an application which helps him get genderwise
--  report for any disease. Write a stored procedure when passed a disease_id returns 4 columns,
-- disease_name, number_of_male_treated, number_of_female_treated, more_treated_gender
-- Where, more_treated_gender is either ‘male’ or ‘female’ based on which gender underwent more often for
--  the disease, if the number is same for both the genders, the value should be
drop procedure  temp2;
delimiter //
create procedure temp2(in disease_id int)
begin 

select max(diseasename),sum(if(p.gender='Male',1,0)) as male_count,
sum(if(p.gender='Female',1,0)) as female_count
,if(sum(if(p.gender='Male',1,0))>sum(if(p.gender='Female',1,0)),'male',
if(sum(if(p.gender='Male',1,0))<sum(if(p.gender='Female',1,0)),'Femlae','Same'))as max  from disease d join 
treatment  t  using (diseaseid)
join person p on t.patientID=p.personid
 where diseaseid= disease_id;
end //
delimiter ;


call temp2(10);
/*Problem Statement 3:  
The insurance companies want a report on the claims of different insurance plans. 
Write a query that finds the top 3 most and top 3 least claimed insurance plans.
The query is expected to return the insurance plan name, 
the insurance company name which has that plan, and whether the plan is the most claimed or least claimed. 
*/

with Claim_Count AS
	(select CompanyID, PlanName, count(claimID) as Claim_Counts, 
		rank() over(order by count(claimID)) as 'Min_r',
		rank() over(order by count(claimID) desc) as 'Max_r'
	from insuranceplan 
	join claim using(UIN)
	group by companyID, planName
	order by claim_Counts)

select PlanName, CompanyName, Claim_Counts, if(min_r<=3, 'Least Claimed', 'Most Claimed') as Claim_Category  from
(select * from Claim_Count where min_r <=3
union 
select * from Claim_Count where max_r <= 3) as r
join insurancecompany using(companyID);

/* Problem Statement 4: 
The healthcare department wants to know which category of patients is being affected the most by each disease.
Assist the department in creating a report regarding this.
Provided the healthcare department has categorized the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.
*/

DELIMITER //
CREATE FUNCTION Person_Category(dob date, gender varchar(50))
	RETURNS VARCHAR(20)
    DETERMINISTIC
    BEGIN
		Declare Category varchar(20);
        if dob > '2005-01-01' and gender = 'Male' then set category = 'YoungMale';
        elseif dob > '2005-01-01' and gender = 'Female' then set category = 'YoungFemale';
        elseif dob > '1985-01-01' and gender = 'Male' then set category = 'AdultMale';
        elseif dob > '1985-01-01' and gender = 'Female' then set category = 'AdultFemale';
        elseif dob > '1970-01-01' and gender = 'Male' then set category = 'MidAgeMale';
        elseif dob > '1970-01-01' and gender = 'Female' then set category = 'MidAgeFemale';
        elseif dob < '1970-01-01' and gender = 'Male' then set category = 'ElderMale';
        elseif dob < '1970-01-01' and gender = 'Female' then set category = 'ElderFemale';
        end if;
        return (category);
	End //
delimiter ;

with patient_info as 
	(select diseaseID, Person_Category(dob, gender) as person_category, count(patientID) as patient_count, 
		rank() over(partition by diseaseID order by count(patientID)) as min_r,
		rank() over(partition by diseaseID order by count(patientID) desc) as max_r    
	from treatment 
	join patient using(patientID)
	join person on person.personID = patient.patientID
	group by diseaseID,person_category)

select * 
from (select diseaseID, group_concat(person_category SEPARATOR ', ') as person_category, patient_count as min_patient_count  from patient_info where min_r = 1 group by diseaseID, patient_count ) as mi
join (select diseaseID, group_concat(person_category SEPARATOR ', ') as person_category, patient_count as max_patient_count  from patient_info where max_r = 1 group by diseaseID, patient_count) as ma
using(diseaseID);


    
/* Problem Statement 5:  
Anna wants a report on the pricing of the medicine. 
She wants a list of the most expensive and most affordable medicines only. 
Assist anna by creating a report of all the medicines which are pricey and affordable, 
listing the companyName, productName, description, maxPrice, and the price category of each. 
Sort the list in descending order of the maxPrice.
Note: A medicine is considered to be “pricey” if the max price exceeds 1000 
and “affordable” if the price is under 5. Write a query to find 
*/

select companyName, productName, description, maxPrice, if(maxprice>1000, 'Pricey', 'Affordable') as 'Price_Category'
from medicine 
where maxPrice > 1000 or maxPrice < 5
order by maxPrice desc;




