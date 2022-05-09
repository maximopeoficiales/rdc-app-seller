CREATE OR REPLACE FUNCTION public.fnt_save_order_detail(
    order_id_p bigint, product_type_id_p bigint, product_id_p varchar,
    quantity_products_p integer, quantity_products_return_p integer, monto_p numeric, monto_affected_p numeric,
    operation_type_id_p integer, reason_operation_id_p integer, product_url_p varchar, flag_offers_p integer,
    offers_p varchar,
    product_p varchar, brand_p varchar, price_by_unit_p numeric,
    price_by_unit_total_p numeric, promotion_code_p varchar, promotion_p varchar, cupon_number_p varchar,
    promotion_discount_amount_p numeric,
    itemn_number_p integer, color_p varchar, size_p varchar,
    suborder_p varchar, type_product_p varchar, seller_name_p varchar, seller_id_p varchar)
    RETURNS boolean
    LANGUAGE plpgsql
AS
$function$
begin
    /*************
      | * Descripcion : FUNCTION public.creategiftcardphysical
      | * Proposito   : Guarda un registro con los datos una giftcard fisica.
      | * Input Parameters:
      |   - <order_id_p>                      	    :Id de la Orden.
      |   - <product_type_id_p>                     :Id del Tipo de Producto.
      |   - <product_id_p>                      	:Id del Producto.
      |   - <quantity_products_p>                   :Cantidad de productos.
      |   - <quantity_products_return_p>            :Cantidad de productos retornados.
      |   - <monto_p>                               :Monto.
      |   - <monto_affected_p>                      :Monto Afectado
      |   - <operation_type_id_p>                   :Id de Tipo de Operacion
      |   - <reason_operation_id_p>                 :Id de la razon de la operacion
      |   - <product_url_p>                         :Url del producto
      |   - <flag_offers_p>                         :Flag de ofertas
      |   - <offers_p>                              :Ofertas
      |   - <product_p>                             :Nombre del Producto
      |   - <brand_p>                               :Marca
      |   - <price_by_unit_p>                       :Precio por Unidad
      |   - <promotion_code_p>                      :Codigo de promocion
      |   - <cupon_number_p>                        :Numero de Cupon
      |   - <promotion_discount_amount_p>           :Monto de Promocion con descuento
      |   - <itemn_number_p>                        :Numero de item
      |   - <color_p>                               :Color
      |   - <size_p>                                :Tamaño
      |   - <suborder_p>                            :Sub orden
      |   - <type_product>                          :Tipo de Producto
      |   - <seller_name_p>                         :Nombre del Seller
      |   - <seller_id_p>                           :Id del Seller
      | * Output Parameters:
      |   - <boolean>                        	  : Estado de resultado.
      | * Autor       : Gianmarcos Perez Rojas.
      | * Proyecto    : RQ 4707 - Cambios y Devoluciones –Devuelve R
      | * Responsable : Cesar Jimenez.
      | * RDC         : RQ 4707
      |
      | * Revisiones
      | * Fecha            Autor       Motivo del cambio            RDC
      | ----------------------------------------------------------------------------
      | - 09/05/22    Maximo Apaza  Creación de la función     RQ 4707
      ************/
    INSERT INTO order_detail(order_id, product_type_id, product_id,
                             quantity_products, quantity_products_return, monto, monto_affected,
                             operation_type_id, reason_operation_id, product_url, flag_offers, offers, product, brand,
                             price_by_unit,
                             price_by_unit_total, promotion_code, promotion, cupon_number, promotion_discount_amount,
                             itemn_number, color, size, suborder, type_product, seller_name, seller_id)
    VALUES (order_id_p, order_id_p, product_type_id_p, product_id_p,
            quantity_products_p, quantity_products_return_p, monto_p, monto_affected_p,
            operation_type_id_p, reason_operation_id_p, product_url_p, flag_offers_p, offers_p, product_p, brand_p,
            price_by_unit_p,
            price_by_unit_total_p, promotion_code_p, promotion_p, cupon_number_p, promotion_discount_amount_p,
            itemn_number_p, color_p, size_p
               , suborder_p, type_product_p, seller_name_p, seller_id_p);

    RETURN true;
end;
$function$
;