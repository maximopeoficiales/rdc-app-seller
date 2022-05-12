create or replace function public.sp_migra_order_msa(ni_order_master_id integer)
    returns table
            (
                order_master_id          bigint,
                order_number             character varying,
                number_order             character varying,
                caja                     character varying,
                sucursal                 character varying,
                purchase_date            character varying,
                transaccion              character varying,
                monto_total              numeric,
                monto_total_return       numeric,
                purchase_type_id         integer,
                purchase_type            character varying,
                identity_document        character varying,
                return_method_id         integer,
                email                    character varying,
                purchase_id              bigint,
                numero_documento         bigint,
                cud                      character varying,
                forma_pago               character varying,
                email_option             character varying,
                name_client              character varying,
                person_first_name        character varying,
                person_last_name         character varying,
                person_identity_document character varying,
                category_id              integer,
                phone                    character varying
            )
    language plpgsql
as
$$

    /*************

        | * descripcion : function public.sp_migra_order_msa

        | * proposito   : función para migrar datos de formulario a cayde.

        | * input parameters:

        |   - <ni_order_master_id>              :id orden compra.

        | * output parameters:

        |   - <order_master_id>                 :id order master.

        |   - <nro_ticket>             			:número de ticket.

        |   - <nro_boleta>               		:número de boleta.

        |   - <nro_caja>          			    :número de caja.

        |   - <nro_sucursal>                    :número de sucursal.

        |   - <fecha>             				:fecha de compra.

        |   - <nro_transaccion>                 :número de transacción.

        |   - <monto_total>          			:monto total.

        |   - <monto_total_return>              :monto total devuelto.

        |   - <purchase_type_id>             	:id tipo compra.

        |   - <purchase_type>                   :tipo de compra.

        |   - <identity_document>          		:documento de identidad.

        |   - <method_id>                       :id metodo devolución.

        |   - <email>             				:correo.

        |   - <purchase_id>                     :id de compra.

        |   - <numero_documento>          		:número de documento.

        |   - <cud>                             :cud.

        |   - <forma_pago>             			:forma de pago.

        |   - <email_option>                    :correo opcional.

        |   - <name_client>          			:nombre del cliente.

        |   - <person_first_name>               :nombre devolucion a terceros.

        |   - <person_last_name>             	:apellidos devolucion a terceros.

        |   - <person_identity_document>        :número de documento devolucion a terceros.

        |   - <category_id>          			:id categoria.

        | * autor       : gianmarcos perez rojas.

        | * proyecto    : rq 4657 - soluciones customer focus: auto-atención / trazabilidad.

        | * responsable : cesar jimenez.

        | * rdc         : rq-4657-14

        |

        | * revisiones

        | * fecha            autor             motivo del cambio            rdc

        | ----------------------------------------------------------------------------

        | - 16/11/21    gianmarcos perez       agregar category_id    rq 4657-14
      | - 09/05/22    maximo apaza  modificacion de la función     rq 4707

    ************/

declare

    -- r order_master%rowtype;

begin

    return query
        select a.order_id as order_master_id,
               a.order_number                              as nro_ticket,

               coalesce(pur.number_order, b1.number_order) as nro_boleta,

               pur.caja                                    as nro_caja,

               pur.sucursal                                as nro_sucursal,

               pur.purchase_date                           as fecha,

               pur.transaccion                             as nro_transaccion,

               a.amount_total                               as monto_total,

               a.amount_total_return                        as monto_total_return,

               a.purchase_type_id,

               c.description                               as purchase_type,

               a.identity_document,

               a.return_method_id                          as method_id,

               a.email,

               a.purchase_id,

               pur.number_document                         as numero_documento,

               pur.cud                                     as cud,

               pur.forma_pago                              as forma_pago,

               a.email_option,

               pur.name_client,

               a.person_first_name,

               a.person_last_name,

               a.person_identity_document,

            /*inicio cambio rq 4657-14*/

               a.category_id,

            /*inicio cambio rq 4657-14*/

               a.phone

        from "order" a

                 inner join public.purchase pur
                            on pur.purchase_id = a.purchase_id

                 left join order_purchase_internet b1
                           on b1.order_master_id = a.order_id

                 left join order_purchase_store b2
                           on b2.order_master_id = a.order_id

                 left join public.purchase_type c
                           on c.purchase_type_id = a.purchase_type_id

        where a.order_id > ni_order_master_id;

end;

$$;