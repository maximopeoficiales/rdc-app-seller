create or replace function public.sp_listar_order_detail_x_tikect(vi_tikect character varying)
    returns table
            (
                order_master_id          bigint,
                order_number             character varying,
                product_name             character varying,
                reason_name              character varying,
                quantity_products_return integer,
                price_by_unit            numeric,
                product_color            character varying,
                product_size             character varying
            )
    language plpgsql
as
$$

begin
     /*************
      | * descripcion : public.sp_listar_order_detail_x_tikect
      | * proposito   : listar registros de order detail por ticket.
      | * input parameters:
      |   - <vi_tikect>                        	  : ticket de la orden.
      | * output parameters:
      |   - <order_master_id>                          :Id de la orden
      |   - <order_number>                            :Numero de la orden
      |   - <product_name>                          :nombre del producto
      |   - <reason_name>                         :nombre de la razon
      |   - <quantity_products_return>                 :cantidad de productos a retornar
      |   - <price_by_unit>                           :precio por unidad
      |   - <product_color>                           :color del producto
      |   - <product_size>                           :tamaño del producto
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
        select om.order_id as order_master_id,
               om.order_number,
               od.product as  product_name,
               ro.description reason_name,
               od.quantity_products_return,
               od.price_by_unit,
               od.color   as  product_color,
               od."size"  as  product_size

        from order om

                 join order_detail od on od.order_id = om.order_id

                 join reason_operation ro on ro.reason_operation_id = od.reason_operation_id

        where od.quantity_products_return > 0
          and om.order_number = vi_tikect;

end;

$$;