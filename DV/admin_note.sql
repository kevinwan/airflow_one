create extension postgis;
select * from spatial_ref_sys srs;

select * from perimeters;

drop table perimeters;

select * from fire_shapefile_core fsc order by poly_creat desc;
select * from fire_shapefile_core_historic fsch 
select count(*) from fire_shapefile_core_historic fsch2 ;

ALTER TABLE perimeters RENAME TO perimeters_old;

select fire_step_nine();


create extension postgres_fdw;

-- In destination_db(DVDEV)
drop server source_server cascade;
CREATE SERVER source_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (dbname 'Disaster_Vision_DB', host 'oc2-analytics01.colo1.veros.com', port '5432');
CREATE USER MAPPING FOR postgres SERVER source_server OPTIONS (user 'postgres', password 'veros110');

--create a foreign table
-- In destination_db
IMPORT FOREIGN SCHEMA public FROM SERVER source_server INTO public;

--- 
select count(*) from address_ca;

select * from address_ca where house_number='45' and  house_street = 'MIDNIGHT SKY' and HOUSE_ZIP='92620'

create index address_ca_inx on address_ca(house_zip,house_street);

select * from address_ca where  house_street = 'MIDNIGHT SKY' and HOUSE_ZIP='92620'



