create or replace function fnt_get_show_forma_pago(order_number_p varchar)
    returns table(forma_pago varchar)
    language plpgsql
as
$$
begin
/*************
      | * descripcion : public.fnt_get_show_forma_pago
      | * proposito   : verifica la forma de pago por numero de orden.
      | * input parameters:
      |   - <order_number_p>                       : numero de orden.
      | * output parameters:
      |   - <forma_pago>                : Forma de pago 
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

	return query
		select p.forma_pago from "order" om
    inner join purchase p
    on p.purchase_id = om.purchase_id
    where om.order_number = order_number_p;
end;
$$;
