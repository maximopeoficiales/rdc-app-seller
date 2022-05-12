create or replace function sp_list_products_by_order(orderid bigint)
    returns table(product_id character varying, quantity_products integer, quantity_products_return integer, quantity_products_return_real integer)
    language plpgsql
as
$$
begin 
/*************
      | * descripcion : function public.sp_list_products_by_order
      | * proposito   : lista todos los productos de una orden.
      | * input parameters:
      |   - <orderid>                      	     :Id de la orden.
      | * output parameters:
      |   - <product_id>                      	    :Id del producto.
      |   - <quantity_products>                   :cantidad de productos.
      |   - <quantity_products_return>            :cantidad de productos retornados.
      |   - <quantity_products_return_real>            :cantidad de productos retornados reales.
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
 select 
	od.product_id, 
	od.quantity_products, 
	od.quantity_products_return,
	(case when od.quantity_products_return_real is null then 0
		 else od.quantity_products_return_real
		 end ) as quantity_products_return_real
 from order_detail od
 where od.order_id = orderid;
end;
$$;


