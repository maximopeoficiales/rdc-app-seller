CREATE OR REPLACE FUNCTION sp_update_qr(ni_order_master_id integer, vi_qr character varying, OUT vo_ind integer, OUT vo_msn character varying) returns record
    language plpgsql
as
$$
DECLARE

    reg RECORD;

	n_seq     bigint := nextval('order_movements_seq');

	v_tikect  text; 

BEGIN 

    vo_ind:= 0;

    vo_msn:= 'Se registro correctamente!!';

    update "order" set id_qr = vi_qr where order_id = ni_order_master_id;

	

END

$$;


