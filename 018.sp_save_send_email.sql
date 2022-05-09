create or replace function sp_save_send_email(ni_order_master_id integer, ni_send_success integer, vi_asunto character varying, vi_destination_email character varying, vi_emails_cc character varying, out vo_ind integer, out vo_msn character varying) returns record
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

   

    if ni_send_success = 1 then	

	    update send_email set status_code = 9 

		where order_master_id = ni_order_master_id and status_code = 8;

    end if;

	

	insert into order_movements(

	order_movements_id, order_id, date_movements, state_movements_id, responsible_code)

	values (n_seq, ni_order_master_id, current_timestamp, 5, 'tess'); 

	insert into send_email(

	request_movements_id, order_master_id, 

	affair, destination_email, emails_cc, state_code_send, send_success, status_code)

	values (n_seq, ni_order_master_id, 

			vi_asunto, vi_destination_email, vi_emails_cc, 5, ni_send_success, ni_send_success);

			

    update "order" set estado_request = 5 where order_id = ni_order_master_id;

	

end

$$;


