create or replace function sp_save_tikect_done_msa(ni_order_detail_id integer, ni_order_id integer,
                                        vi_product_id character varying, ni_quantity_products_return_real integer,
                                        ni_monto_affected_real numeric, ni_flag_return integer,
                                        ni_reason_operation_id integer, out vo_ind integer,
                                        out vo_msn character varying) returns record
    language plpgsql
as
$$
declare
    reg      record;
    n_seq    bigint  := nextval('order_movements_seq');
    v_tikect text;
    n_state  integer := 4;
begin
          /*************
      | * descripcion : public.sp_save_tikect_done_msa
      | * proposito   : actualiza el order detail para guardar el ticket de finalizado del msa.
      | * input parameters:
      |   - <ni_order_detail_id>                      	 :Id de la orden de detalle.
      |   - <ni_order_id>                      	 :Id de la orden.
      |   - <vi_product_id>                      	 :Id del producto.
      |   - <ni_quantity_products_return_real>       :Cantiddd del productos real.
      |   - <ni_monto_affected_real>                      	 :Monto real afectado.
      |   - <ni_flag_return>                      	 :Indicador de retornado.
      |   - <ni_reason_operation_id>                      	 :Id de la razon de operacion.
      |   - <vo_ind>                      	    :ind.
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
    vo_ind := 0;
    vo_msn := 'se registro correctamente!!';
    /*
    insert into order_movements(
    order_movements_id, order_id, date_movements, state_movements_id, responsible_code)
    values (n_seq, ni_order_master_id, current_timestamp, n_state, 'tess'); 
    update order_master set estado_request = n_state where order_master_id = ni_order_master_id;
    */

    update order_detail
    set flag_return                   = ni_flag_return,
        quantity_products_return_real = ni_quantity_products_return_real,
        monto_affected_real           = ni_monto_affected_real
    where order_id = ni_order_id
      and product_id = vi_product_id;

end
$$;


