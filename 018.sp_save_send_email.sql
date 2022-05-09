create function sp_save_send_email(ni_order_master_id integer, ni_send_success integer, vi_asunto character varying, vi_destination_email character varying, vi_emails_cc character varying, OUT vo_ind integer, OUT vo_msn character varying) returns record
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

   

    if ni_send_success = 1 then	

	    update send_email set status_code = 9 

		where order_master_id = ni_order_master_id and status_code = 8;

    end if;

	

	INSERT INTO order_movements(

	order_movements_id, order_id, date_movements, state_movements_id, responsible_code)

	VALUES (n_seq, ni_order_master_id, CURRENT_TIMESTAMP, 5, 'TESS'); 

	INSERT INTO send_email(

	request_movements_id, order_master_id, 

	affair, destination_email, emails_cc, state_code_send, send_success, status_code)

	VALUES (n_seq, ni_order_master_id, 

			vi_asunto, vi_destination_email, vi_emails_cc, 5, ni_send_success, ni_send_success);

			

    update "order" set estado_request = 5 where order_id = ni_order_master_id;

	

END

$$;


