CREATE OR REPLACE FUNCTION sp_save_state_done_msa(ni_order_master_id integer, ni_state integer, OUT vo_ind integer, OUT vo_msn character varying) returns record
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
	INSERT INTO order_movements(
	order_movements_id, order_id, date_movements, state_movements_id, responsible_code)
	VALUES (n_seq, ni_order_master_id, CURRENT_TIMESTAMP, ni_state, 'TESS'); 
    update "order" set estado_request = ni_state where order_id = ni_order_master_id;
	
END
$$;


