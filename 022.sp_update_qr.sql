create or replace function sp_update_qr(ni_order_master_id integer, vi_qr character varying, out vo_ind integer, out vo_msn character varying) returns record
    language plpgsql
as
$$
declare

    reg record;

	n_seq     bigint := nextval('order_movements_seq');

	v_tikect  text; 

begin 

    vo_ind:= 0;

    vo_msn:= 'se registro correctamente!!';

    update "order" set id_qr = vi_qr where order_id = ni_order_master_id;

	

end

$$;


