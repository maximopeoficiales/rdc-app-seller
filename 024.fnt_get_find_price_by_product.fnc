create or replace function fnt_get_find_price_by_product(order_id_p bigint,product_id_p varchar)
    returns table(price_by_unit numeric,product varchar,product_url varchar,suborder varchar,type_product varchar,seller_name varchar,
    seller_id varchar)
    language plpgsql
as
$$
begin
    /*************
      | * descripcion : public.fnt_get_find_price_by_product
      | * proposito   : busca precio por producto.
      | * input parameters:
      |   - <order_id_p>                        : Id de la orden.
      |   - <product_id_p>                         : Id del producto.
      | * output parameters:
      |   - <price_by_unit>                : Precio por unidad 
      |   - <product>                : Nombre del producto 
      |   - <product_url>                : url del producto 
      |   - <suborder>                 : sub orden 
      |   - <type_product>                 : tipo del producto 
      |   - <seller_name>                  : nombre del seller 
      |   - <seller_id>                   : id del seller 
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
select pd.price_by_unit, pd.product, pd.product_url,
            pd.suborder, pd.type_product, pd.seller_name, pd.seller_id
            from "order" om inner join purchase_detail pd
            on om.purchase_id = pd.purchase_id where om.order_id =  order_id_p
            and pd.product_id = product_id_p order by om.order_id desc limit 1;
end;
$$;
