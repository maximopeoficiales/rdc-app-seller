create or replace function sp_listar_detail_email_for_send(ni_order_master_id integer)
    returns table
            (
                order_detail_id               bigint,
                order_master_id               bigint,
                product_type_id               bigint,
                product_id                    character varying,
                quantity_products             integer,
                quantity_products_return      integer,
                monto                         numeric,
                monto_affected                numeric,
                operation_type_id             integer,
                reason_operation_id           integer,
                product_url                   character varying,
                flag_offers                   integer,
                offers                        character varying,
                product                       character varying,
                classification_products_id    bigint,
                model                         character varying,
                size                          character varying,
                image                         character varying,
                brand                         character varying,
                quantity_products_return_real integer,
                monto_affected_real           numeric,
                flag_return                   integer,
                price_by_unit                 numeric,
                days_expiration               integer,
                expiration_date               date,
                seller_name                   character varying
            )
    language plpgsql
as
$$
    /*************
   
     | * descripcion : function public.sp_listar_detail_email_for_send
   
     | * proposito   : funcion para obtener el detalle de los correos.
   
     | * input parameters:
   
     | * output parameters:
   
     |   - <order_detail_id>                   :id del detalle de la orden.
   
     |   - <order_master_id>                    :id de la orden creada en el formulario.
   
     |   - <product_type_id>                      :tipo del producto.
   
     |   - <product_id>                 :identificador del producto.
   
     |   - <quantity_products>                 			:cantidad de productos.
   
     |   - <quantity_products_return>                  :cantidad de productos a retornar.
   
     |   - <monto>                     :monto.
   
     |   - <monto_affected>                   :monto afectado.
   
     |   - <operation_type_id>            :tipo de operacion.
   
     |   - <reason_operation_id>            :motivo de devolucion.
   
     |   - <product_url>            :url del producto.
   
     |   - <flag_offers>                       :estado de la oferta.
   
     |   - <offers>                :oferta.
   
     |   - <product>                :nombre del producto.
   
     |   - <classification_products_id>                    :id clasificacion del producto.
   
     |   - <model>                   :modelo del producto.
   
     |   - <size>                             :talla del producto.
   
     |   - <image>                       :imagen del producto.
   
     |   - <brand>                   		:marca del producto.
   
     |   - <quantity_products_return_real>                  :cantidad del productos.
   
     |   - <monto_affected_real>                          :monto afectado.
   
     |   - <flag_return>                      :estado de retorno.
   
     |   - <price_by_unit_total>                :precio total.
   
     |   - <days_expiration>                :dias de expiracion.
   
     |   - <expiration_date>                :fecha de expiracion.
   
     |   - <seller_name>                :nombre del vendedor.
   
     | * autor       : gianmarcos perez rojas.
   
     | * proyecto    : rq 4657 - soluciones customer focus: auto-atención / trazabilidad.
   
     | * responsable : cesar jimenez.
   
     | * rdc         : rq-4657-8
   
     |
   
     | * revisiones
   
     | * fecha            autor       motivo del cambio            rdc
   
     | ----------------------------------------------------------------------------
   
     | - 14/09/21    gianmarcos perez se agrega sucursal y trx     rq 4657-8   
   
     | - 30/03/22    paulo carbajal nombre del vendedor            rq 4707-4                                                             
     | - 09/05/22    maximo apaza   modificacion de funcion            rq 4707                                                            
   
     ************/

declare

    r               order_detail%rowtype;
    d_purchase_date date;
    n_purchase_id   int8;

begin

    select a.purchase_date, a.purchase_id
    into d_purchase_date, n_purchase_id

    from "order" a

             left join purchase b
                       on b.purchase_id = a.purchase_id

    where a.order_id = ni_order_master_id;


    return query
        select a.order_detail_id,
               a.order_id as order_master_id,
               a.product_type_id,
               a.product_id,
               a.quantity_products,

               a.quantity_products_return,
               a.monto,
               a.monto_affected,
               a.operation_type_id,
               a.reason_operation_id,

               a.product_url,
               a.flag_offers,
               a.offers,
               a.product,
               a.classification_products_id,
               a.model,
               a.size,
               a.image,

               a.brand,
               a.quantity_products_return_real,
               a.monto_affected_real,
               a.flag_return,
               a.price_by_unit_total,

               coalesce(pd.days_expiration, 60) as                days_expiration,
               d_purchase_date + coalesce(pd.days_expiration, 60) expiration_date,

               a.seller_name

        from order_detail a

                 left join purchase_detail pd
                           on pd.product_id = a.product_id and
                              pd.purchase_id = n_purchase_id and
                              pd.suborder = pd.suborder

        where a.order_id = ni_order_master_id
          and a.quantity_products_return > 0;

end;

$$;


