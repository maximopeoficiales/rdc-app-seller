create or replace function sp_save_state_done_msa(ni_order_master_id integer, ni_state integer, out vo_ind integer, out vo_msn character varying) returns record
    language plpgsql
as
$$
declare
    reg record;
	n_seq     bigint := nextval('order_movements_seq');
	v_tikect  text; 
begin 
        /*************
      | * descripcion : public.sp_save_state_done_msa
      | * proposito   : guarda el estado del msa en la tabla order.
      | * input parameters:
      |   - <ni_order_master_id>                      	 :Id de la orden.
      |   - <ni_state>                      	    :Estado del msa.
      |   - <vo_ind>                      	    :asunto.
      |   - <vo_msn>                      	    :msn.
      | * output parameters:
      |   - <record>                       : .
      | * autor       : gianmarcos perez rojas.
      | * proyecto    : rq 4707 - cambios y devoluciones –devuelve r
      | * responsable : cesar jimenez.
      | * rdc         : rq 4707
      |
      | * revisiones
      | * fecha            autor       motivo del cambio            rdc
      | ----------------------------------------------------------------------------
      | - 09/05/22    maximo apaza  modificacion de la función     rq 4707
      ************/
    vo_ind:= 0;
    vo_msn:= 'se registro correctamente!!';
	insert into order_movements(
	order_movements_id, order_id, date_movements, state_movements_id, responsible_code)
	values (n_seq, ni_order_master_id, current_timestamp, ni_state, 'tess'); 
    update "order" set estado_request = ni_state where order_id = ni_order_master_id;
	
end
$$;


