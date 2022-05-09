create or replace function sp_update_qr(ni_order_master_id integer, vi_qr character varying, out vo_ind integer, out vo_msn character varying) returns record
    language plpgsql
as
$$
declare

    reg record;

	n_seq     bigint := nextval('order_movements_seq');

	v_tikect  text; 

begin 
              /*************
      | * descripcion : public.sp_update_qr
      | * proposito   : actualiza el qr.
      | * input parameters:
      |   - <ni_order_master_id>                :Id de la orden 
      |   - <vi_qr>                       :qr 
      |   - <vo_ind>                :ind 
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

    update "order" set id_qr = vi_qr where order_id = ni_order_master_id;

	

end

$$;


