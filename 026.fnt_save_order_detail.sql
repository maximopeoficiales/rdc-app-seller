create or replace function public.fnt_save_order_detail(
    order_id_p bigint, product_type_id_p bigint, product_id_p varchar,
    quantity_products_p integer, quantity_products_return_p integer, monto_p numeric, monto_affected_p numeric,
    operation_type_id_p integer, reason_operation_id_p integer, product_url_p varchar, flag_offers_p integer,
    offers_p varchar,
    product_p varchar, brand_p varchar, price_by_unit_p numeric,
    price_by_unit_total_p numeric, promotion_code_p varchar, promotion_p varchar, cupon_number_p varchar,
    promotion_discount_amount_p numeric,
    itemn_number_p integer, color_p varchar, size_p varchar,
    suborder_p varchar, type_product_p varchar, seller_name_p varchar, seller_id_p varchar)
    returns boolean
    language plpgsql
as
$function$
begin
    /*************
      | * descripcion : public.fnt_save_order_detail
      | * proposito   : guarda un registro en la tabla order detail.
      | * input parameters:
      |   - <order_id_p>                      	    :id de la orden.
      |   - <product_type_id_p>                     :id del tipo de producto.
      |   - <product_id_p>                      	:id del producto.
      |   - <quantity_products_p>                   :cantidad de productos.
      |   - <quantity_products_return_p>            :cantidad de productos retornados.
      |   - <monto_p>                               :monto.
      |   - <monto_affected_p>                      :monto afectado
      |   - <operation_type_id_p>                   :id de tipo de operacion
      |   - <reason_operation_id_p>                 :id de la razon de la operacion
      |   - <product_url_p>                         :url del producto
      |   - <flag_offers_p>                         :flag de ofertas
      |   - <offers_p>                              :ofertas
      |   - <product_p>                             :nombre del producto
      |   - <brand_p>                               :marca
      |   - <price_by_unit_p>                       :precio por unidad
      |   - <promotion_code_p>                      :codigo de promocion
      |   - <cupon_number_p>                        :numero de cupon
      |   - <promotion_discount_amount_p>           :monto de promocion con descuento
      |   - <itemn_number_p>                        :numero de item
      |   - <color_p>                               :color
      |   - <size_p>                                :tamaño
      |   - <suborder_p>                            :sub orden
      |   - <type_product>                          :tipo de producto
      |   - <seller_name_p>                         :nombre del seller
      |   - <seller_id_p>                           :id del seller
      | * output parameters:
      |   - <boolean>                        	  : estado de resultado.
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
    insert into order_detail(order_id, product_type_id, product_id,
                             quantity_products, quantity_products_return, monto, monto_affected,
                             operation_type_id, reason_operation_id, product_url, flag_offers, offers, product, brand,
                             price_by_unit,
                             price_by_unit_total, promotion_code, promotion, cupon_number, promotion_discount_amount,
                             itemn_number, color, size, suborder, type_product, seller_name, seller_id)
    values (order_id_p, order_id_p, product_type_id_p, product_id_p,
            quantity_products_p, quantity_products_return_p, monto_p, monto_affected_p,
            operation_type_id_p, reason_operation_id_p, product_url_p, flag_offers_p, offers_p, product_p, brand_p,
            price_by_unit_p,
            price_by_unit_total_p, promotion_code_p, promotion_p, cupon_number_p, promotion_discount_amount_p,
            itemn_number_p, color_p, size_p
               , suborder_p, type_product_p, seller_name_p, seller_id_p);

    return true;
end;
$function$
;