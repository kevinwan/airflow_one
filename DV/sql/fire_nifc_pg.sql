--make sure to run the following SQLs 
--under the right scheme rather than "public"
--since they may already exist under public 

--step_init
CREATE OR REPLACE FUNCTION fire_initial_step()
 RETURNS void
 LANGUAGE sql
AS $function$
insert into fire_shapefile_core_historic
select objectid,poly_incid,poly_gisac,poly_creat,poly_acres,poly_globa,irwin_esti,irwin_fire,irwin_perc
irwin_poof
from fire_shapefile_core;
drop table if exists  fire_shapefile_core;
--Rename the source file
ALTER TABLE "wfigs_-_current_wildland_fire_perimeters"
RENAME TO fire_shapefile_core;
$function$
;


--step_1
CREATE OR REPLACE FUNCTION fire_step_one()
 RETURNS void
 LANGUAGE sql
AS $function$
insert into fire_shapefile_core_historic
select objectid,poly_incid,poly_gisac,poly_creat,poly_acres,poly_globa,irwin_esti,irwin_fire,irwin_perc
irwin_poof
from fire_shapefile_core;
$function$
;

--step_2
CREATE OR REPLACE FUNCTION fire_step_two()
 RETURNS void
 LANGUAGE sql
AS $function$
drop table if exists  fire_shapefile_core;
ALTER TABLE Perimeters
RENAME TO fire_shapefile_core;
$function$
;

--step_3
CREATE OR REPLACE FUNCTION fire_step_three()
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE
 sec NUMERIC(10);
BEGIN
 sec := (select count(*)  from(select * from fire_shapefile_core_historic
							   except
							   select objectid,poly_incid,poly_gisac,poly_creat,poly_acres,poly_irwin as poly_globa
							   ,attr_incid as irwin_esti,attr_firem as irwin_fire,attr_perce as irwin_perc
							   from fire_shapefile_core) j);
RETURN sec;
END;
$function$
;

--step_4
CREATE OR REPLACE FUNCTION fire_step_four()
 RETURNS void
 LANGUAGE sql
AS $function$
drop table if exists  fire_shapefile_buffer;
select *,st_buffer(core.geom, 0.002745) as Buffer_geom into fire_shapefile_buffer from fire_shapefile_core as core;
CREATE INDEX geom_gindx_buffer
    ON fire_shapefile_buffer USING gist
    (Buffer_geom)
    TABLESPACE pg_default;
$function$
;

--step_5
CREATE OR REPLACE FUNCTION fire_step_five()
 RETURNS void
 LANGUAGE sql
AS $function$
drop table if exists  fire_shapefile_core_mapped_2;
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,irwin_perc into fire_shapefile_core_mapped_2 from (
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from address_ca a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_nm a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
			,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
			from public.address_az a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
			union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_co a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_fl a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_hi a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_nv a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_or a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_ut a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_wa a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_or a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_tx a join fire_shapefile_core b on ST_Contains( b.geom,a.geom)
		)i;
$function$
;

--step_6
CREATE OR REPLACE FUNCTION fire_step_six()
 RETURNS void
 LANGUAGE sql
AS $function$
drop table if exists  fire_shapefile_buffer_mapped;
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,irwin_perc into fire_shapefile_buffer_mapped from (
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_ca a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_nm a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
			,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
			from public.address_az a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
			union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_co a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_fl a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_hi a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_nv a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_or a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_ut a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_wa a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_tx a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_nc a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		union
		select house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number,house_zip,state,fips_county_name,fips_county_code,poly_incid
		,objectid,poly_polyg as irwin_cr_1,avs_latitude,avs_longitude,apn,owner_record,seq_no,attr_perce as irwin_perc 
		from public.address_mn a join fire_shapefile_buffer b on ST_Contains( b.Buffer_geom,a.geom)
		)i;
$function$
;

--step_7
CREATE OR REPLACE FUNCTION fire_step_seven()
 RETURNS void
 LANGUAGE sql
AS $function$
drop table if exists  fire_BKFS_file;
select (case when HOUSE_NUMBER='-1' then null else HOUSE_NUMBER end) as HOUSE_NUMBER,
(case when HOUSE_DIRECTION='-1' then null else HOUSE_DIRECTION end) as HOUSE_DIRECTION,
(case when HOUSE_STREET='-1' then null else HOUSE_STREET end) as HOUSE_STREET,
(case when HOUSE_STREET_MODE='-1' then null else HOUSE_STREET_MODE end) as HOUSE_STREET_MODE,
(case when HOUSE_MODE_DIRECTION='-1' then null else HOUSE_MODE_DIRECTION end) as HOUSE_MODE_DIRECTION,
(case when HOUSE_CITY='-1' then null else HOUSE_CITY end) as HOUSE_CITY,
(case when HOUSE_UNIT_NUMBER='-1' then null else HOUSE_UNIT_NUMBER end) as HOUSE_UNIT_NUMBER,
(case when HOUSE_ZIP='-1' then null else HOUSE_ZIP end) as HOUSE_ZIP,
(case when STATE='-1' then null else STATE end) as STATE,FIPS_COUNTY_NAME,FIPS_COUNTY_CODE,VEROS_IDENTIFIER
,DISASTER_INDICATOR as DISASTER_IDENTIFIER,h.poly_incid as DISASTER_NAME,cast('Wildfire' as varchar(10)) as DISASTER_TYPE
		,concat(h.objectid,'_',h.poly_incid) as DISASTER_ID,h.irwin_cr_1 as VEROS_START_DATE,VEROS_END_DATE,AVS_LATITUDE,AVS_LONGITUDE,FILE_RUN_DATE,FEMA_INCIDENT_START_DATE
		,FEMA_INCIDENT_END_DATE,EVENT_TERMINATION,BKFS_INDICATOR,APN,DISASTER_NARRATIVE,PEAK_SEVERITY,GEOBOX_N
		,GEOBOX_S,GEOBOX_E,GEOBOX_W,FEMA__DR_DECLARATION_DATE,FEMA__FM_DECLARATION_DATE,FEMA__EM_DECLARATION_DATE,OWNER_RECORD   into fire_BKFS_file
		from (select distinct a.*,(case when b.seq_no is null then 'IN BUFFER' else 'INSIDE EVENT' end ) as DISASTER_INDICATOR
		,concat(a.fips_county_code,'_',a.seq_no) as VEROS_IDENTIFIER
		,(case when a.irwin_perc=100 then 'Y' else 'N' end) as EVENT_TERMINATION
		,current_date as FILE_RUN_DATE
		,null as VEROS_END_DATE
		,null as FEMA_INCIDENT_START_DATE
		,null as FEMA_INCIDENT_END_DATE
		,null as BKFS_INDICATOR
		,null as DISASTER_NARRATIVE
		,null as PEAK_SEVERITY
		,null as FEMA__DR_DECLARATION_DATE		
		,null as FEMA__FM_DECLARATION_DATE
		,null as FEMA__EM_DECLARATION_DATE
		from fire_shapefile_buffer_mapped a left join 
		fire_shapefile_core_mapped_2 b on a.fips_county_code=b.fips_county_code and a.seq_no=b.seq_no) h
		join (select objectid,poly_incid, max(cast(avs_latitude as float)) as geobox_n,
min(cast(avs_latitude as float)) as geobox_s,
max(cast(avs_longitude as float)) as geobox_e,
min(cast(avs_longitude as float)) as geobox_w
from fire_shapefile_buffer_mapped
group by objectid,poly_incid) u on h.objectid=u.objectid and h.poly_incid=u.poly_incid
and EVENT_TERMINATION<>'Y';
$function$
;

--step_8
CREATE OR REPLACE FUNCTION fire_step_eight()
 RETURNS void
 LANGUAGE sql
AS $function$
insert into disaster_id_file
select a.disaster_name
,((select max(cast(disaster_id as integer)) as disaster_id from disaster_id_file)+row_number()over(order by a.disaster_name)) AS disaster_id
from fire_bkfs_file a left join disaster_id_file b on a.disaster_name=b.disaster_name
where b.disaster_name is null
group by a.disaster_name;
$function$
;

--step_9
CREATE OR REPLACE FUNCTION public.fire_step_nine()
 RETURNS void
 LANGUAGE sql
AS $function$
COPY (SELECT house_number,house_direction,house_street,house_street_mode,house_mode_direction,house_city,house_unit_number
	  ,house_zip,state,fips_county_name,fips_county_code,veros_identifier,disaster_identifier,
	   a.disaster_name,disaster_type,b.disaster_id,to_char(veros_start_date, 'MM/DD/YYYY') as veros_start_date
	   ,veros_end_date,avs_latitude,avs_longitude
	   ,to_char(file_run_date, 'MM/DD/YYYY') as file_run_date,fema_incident_start_date,fema_incident_end_date,event_termination,bkfs_indicator,apn,disaster_narrative,peak_severity,geobox_n,geobox_s,geobox_e,geobox_w,fema__dr_declaration_date,fema__fm_declaration_date,fema__em_declaration_date,owner_record
 FROM public.fire_bkfs_file a join public.disaster_id_file b on a.disaster_name=b.disaster_name 
	 where  avs_latitude>'0' and avs_latitude not like '%e%' and veros_start_date is not null) 
 TO '/var/lib/DV/bkfs/Check_folder/Demofire.txt' WITH DELIMITER E'\t' NULL AS '';
$function$
;
