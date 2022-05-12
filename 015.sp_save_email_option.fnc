create or replace function public.sp_save_email_option(email_option_save character varying, id_order_master integer)
    returns table
            (
                state_email_option integer
            )
    language plpgsql
as
$$

begin
        /*************
      | * descripcion : public.sp_save_email_option
      | * proposito   : actualizacion de registro en la tabla order.
      | * input parameters:
      |   - <email_option_save>                      	 :Opcion del email a guardar.
      |   - <id_order_master>                      	    :id de la orden.
      | * output parameters:
      |   - <state_email_option>                       : estado del email.
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

    update "order"
    set estado_request     = 2,
        email_option       = email_option_save,
        state_email_option = 1
    where order_id = id_order_master;

    return query
        select o.state_email_option

        from "order" o
        where o.order_id = id_order_master;

end;
$$;