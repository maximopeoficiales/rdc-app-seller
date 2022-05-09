CREATE OR REPLACE FUNCTION public.sp_migra_order_msa(ni_order_master_id integer)
    RETURNS TABLE
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
    LANGUAGE plpgsql
AS
$$

    /*************

        | * Descripcion : FUNCTION public.sp_migra_order_msa

        | * Proposito   : Función para migrar datos de formulario a cayde.

        | * Input Parameters:

        |   - <ni_order_master_id>              :Id orden compra.

        | * Output Parameters:

        |   - <order_master_id>                 :Id order master.

        |   - <nro_ticket>             			:Número de ticket.

        |   - <nro_boleta>               		:Número de boleta.

        |   - <nro_caja>          			    :Número de caja.

        |   - <nro_sucursal>                    :Número de sucursal.

        |   - <fecha>             				:Fecha de compra.

        |   - <nro_transaccion>                 :Número de transacción.

        |   - <monto_total>          			:Monto total.

        |   - <monto_total_return>              :Monto total devuelto.

        |   - <purchase_type_id>             	:Id tipo compra.

        |   - <purchase_type>                   :Tipo de compra.

        |   - <identity_document>          		:Documento de identidad.

        |   - <method_id>                       :Id Metodo devolución.

        |   - <email>             				:Correo.

        |   - <purchase_id>                     :Id de compra.

        |   - <numero_documento>          		:Número de documento.

        |   - <cud>                             :Cud.

        |   - <forma_pago>             			:Forma de pago.

        |   - <email_option>                    :Correo opcional.

        |   - <name_client>          			:Nombre del cliente.

        |   - <person_first_name>               :Nombre devolucion a terceros.

        |   - <person_last_name>             	:Apellidos devolucion a terceros.

        |   - <person_identity_document>        :Número de documento devolucion a terceros.

        |   - <category_id>          			:Id Categoria.

        | * Autor       : Gianmarcos Perez Rojas.

        | * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

        | * Responsable : Cesar Jimenez.

        | * RDC         : RQ-4657-14

        |

        | * Revisiones

        | * Fecha            Autor             Motivo del cambio            RDC

        | ----------------------------------------------------------------------------

        | - 16/11/21    Gianmarcos Perez       Agregar category_id    RQ 4657-14

    ************/

DECLARE

    -- r order_master%rowtype;

BEGIN

    RETURN QUERY
        SELECT a.order_id as order_master_id,
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

            /*INICIO CAMBIO RQ 4657-14*/

               a.category_id,

            /*INICIO CAMBIO RQ 4657-14*/

               a.phone

        FROM "order" a

                 inner join public.purchase pur
                            on pur.purchase_id = a.purchase_id

                 LEFT JOIN order_purchase_internet b1
                           ON b1.order_master_id = a.order_id

                 LEFT JOIN order_purchase_store b2
                           ON b2.order_master_id = a.order_id

                 LEFT JOIN public.purchase_type c
                           ON c.purchase_type_id = a.purchase_type_id

        WHERE a.order_id > ni_order_master_id;

END;

$$;