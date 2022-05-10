create or replace function public.fnt_save_seller(id_seller_mirakl)
    returns table(sucursal varchar)
    language plpgsql
as
$function$
begin
    /*************
      | * descripcion : public.fnt_find_sucursal_x_ticket
      | * proposito   : buscar sucurusal por ticket.
      | * input parameters:
      |   - <order_id_p>                      	    :id de la orden.
      | * output parameters:
      |   - <sucursal>                        	  : Sucursal.
      | * autor       : gianmarcos perez rojas.
      | * proyecto    : rq 4707 - cambios y devoluciones –devuelve r
      | * responsable : cesar jimenez.
      | * rdc         : rq 4707
      |
      | * revisiones
      | * fecha            autor       motivo del cambio            rdc
      | ----------------------------------------------------------------------------
      | - 09/05/22    maximo apaza  creación de la función     rq 4707
      ************/
return query
select p.sucursal from "order" om inner join purchase p
      on p.purchase_id = om.purchase_id where om.order_id = order_id_p;
end;
$function$
;