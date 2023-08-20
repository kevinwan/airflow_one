shp2pgsql -s 0 "/var/lib/DV/Fire_process/Perimeters.shp" public.perimeters | psql -h oc2-analytics01.colo1.veros.com -U postgres -d DVDEV -W veros110
