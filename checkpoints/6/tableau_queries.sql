/*1. Which pairings between identity groups of officers and their respective accusers are most common? (One axis is officer
identity group, the other axis is accuser identity group. Each intersection of officer and accuser is a datapoint of number 
of instances. Data points are larger with greater number of instances.)*/

CREATE TABLE vis1_1 AS 
        WITH pairing_allegations AS 
             (SELECT c.race as complainant_race, o.race as officer_race, c.gender as complainant_gender, o.gender as officer_gender, oa.disciplined 
                FROM data_allegation a, data_officerallegation oa, data_officer o, data_complainant c 
               WHERE o.id = a.id AND o.id = oa.officer_id AND c.allegation_id = a.id)
      SELECT complainant_race, officer_race, complainant_gender, officer_gender, COUNT(*)
        FROM pairing_allegations 
       WHERE complainant_race is NOT NULL AND officer_race is NOT NULL AND complainant_gender is NOT NULL AND officer_gender is NOT NULL 
       GROUP BY complainant_race, officer_race, complainant_gender, officer_gender;

\copy vis1_1 to '/Users/caseygrage/Downloads/vis1_1.csv' WITH (FORMAT csv);


/*2. Which identity groups make an officer most likely to have an allegation? (Pie chart/bar graph)*/

CREATE TABLE vis2_1 AS
        WITH pairing_allegations AS 
             (SELECT c.race as complainant_race, o.race as officer_race, c.gender as complainant_gender, o.gender as officer_gender, oa.disciplined 
                FROM data_allegation a, data_officerallegation oa, data_officer o, data_complainant c 
               WHERE o.id = a.id AND o.id = oa.officer_id AND c.allegation_id = a.id) 
      SELECT officer_race, officer_gender, COUNT(*) 
        FROM pairing_allegations 
       WHERE officer_race is NOT NULL AND officer_gender is NOT NULL 
       GROUP BY officer_race, officer_gender;

\copy vis2_1 to '/Users/caseygrage/Downloads/vis2_1.csv' WITH (FORMAT csv);

/*I’ve only looked at COUNTS of different variables. But these counts are pretty meaningless without comparing identity 
groups to the overall police or civilian populations. So here is a spreadsheet of the officers with allegations (broken 
down by race/gender) as well as the totals of each race/gender from the police officer.*/

CREATE TABLE vis2_2 AS
        WITH officer_totals AS 
             (SELECT COUNT (distinct o.id) as total_count, o.race as officer_race, o.gender as officer_gender 
                FROM data_officer o 
               WHERE o.race is NOT NULL 
               GROUP BY o.race, o.gender) 
      SELECT officer_race, officer_gender, COUNT(*) as alleg_count, 100*(COUNT(*)/total_count) as percentage 
        FROM officer_totals 
       WHERE officer_race is NOT NULL AND officer_gender is NOT NULL
       GROUP BY officer_race, officer_gender, total_count;


/*3. What identity groups of civilians make them more likely to file complaints/accusations for each type of harassment?
(Pie chart/bar graph)
Need table of complainant_gender, complainant_race, and type of harassment...*/

CREATE TABLE vis3_1 AS
        WITH pairing_allegations AS
             (SELECT c.race as complainant_race, c.gender as complainant_gender, ac.category as alleg_category
                FROM data_allegation a, data_officerallegation oa, data_officer o, data_complainant c, data_allegationcategory ac 
               WHERE o.id = a.id AND o.id = oa.officer_id AND c.allegation_id = a.id AND oa.allegation_category_id = ac.id)
      SELECT complainant_race, complainant_gender, alleg_category, COUNT(*) FROM pairing_allegations 
       WHERE complainant_race is NOT NULL AND complainant_gender is NOT NULL 
       GROUP BY complainant_race, complainant_gender, alleg_category;

\copy vis3_1 to '/Users/caseygrage/Downloads/vis3_1.csv' WITH (FORMAT csv);


/*4. What identity groups of officers make them more likely to have complaints/accusations for each type of harassment filed 
against them? (highlight table)
Need table of officer_gender, officer_race, and type of harassment*/

CREATE TABLE vis4_1 AS
        WITH pairing_allegations AS 
             (SELECT o.race as officer_race, o.gender as officer_gender, ac.category as alleg_category 
                FROM data_allegation a, data_officerallegation oa, data_officer o, data_complainant c, data_allegationcategory ac 
               WHERE o.id = a.id AND o.id = oa.officer_id AND c.allegation_id = a.id AND oa.allegation_category_id = ac.id) 
      SELECT officer_race, officer_gender, alleg_category, COUNT(*) 
        FROM pairing_allegations 
       WHERE officer_race is NOT NULL AND officer_gender is NOT NULL 
       GROUP BY officer_race, officer_gender, alleg_category;

\copy vis4_1 to '/Users/caseygrage/Downloads/vis4_1.csv' WITH (FORMAT csv);

/*To account for gender and racial breakdown of actual police force compared to the number of allegations by gender of race:
Use this query to get totals of race and gender in police force:*/

SELECT COUNT (distinct o.id), o.race, o.gender 
  FROM data_officer o 
 WHERE o.race is NOT NULL 
 GROUP BY o.race, o.gender;

/*All that data can be added to the previous vis4_1 table as  a column using a simple python statement (just wherever 
race = ___ and gender = ___, fill the ‘total’ column with the corresponding total from the above select statement. 
The percentage can be calculated by dividing the no. allegation column by the total count column and multiplying by 100.*/
