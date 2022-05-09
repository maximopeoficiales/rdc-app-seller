CREATE OR REPLACE FUNCTION sp_list_order_store(vi_sucursal character varying, vi_caja character varying, vi_purchase_date character varying, vi_transaction character varying)
    returns TABLE(estado_request integer[], estado character varying[], product_id character varying, quantity_products integer, quantity_products_return bigint, reason_operation_id integer, reason_operation text, operation_type_id integer, operation_type text, flag_offers integer, flag_returned integer, flag_blocking integer, type_blocking integer, description_blocking text, sub_title_fecha text, condition character varying, days_expiration integer, flag_mostrar integer)
    language plpgsql
as
$$
    /*************

    | * Descripcion : FUNCTION public.sp_list_order_store

    | * Proposito   : Función para listar las ordenes de tiendas fisicas.

    | * Input Parameters:

    |   - <vi_sucursal>                           		:Sucursal.

    |   - <vi_caja>                           			:Caja.

    |   - <vi_purchase_date>                           	:Fecha de compra.

    |   - <vi_transaction>                           	:Transaccion.

    | * Output Parameters:

    |   - <estado_request>                                 :Estado de solicitud.

    |   - <estado>                                         :Estado.

    |   - <product_id>                                     :ID del producto.

    |   - <quantity_products>                              :Cantidad de productos.

    |   - <quantity_products_return>                       :Cantidad de productos devueltos.

    |   - <reason_operation_id>                            :Sucursal.

    |   - <reason_operation>                               :Monto.

    |   - <operation_type_id>                              :Monto afecto.

    |   - <operation_type>                                 :Tipo de operación.

    |   - <flag_offers>                                    :Bandera de oferta.

    |   - <flag_returned>                                  :Bandera de retorno.

    |   - <flag_blocking>                                  :Bandera de bloqueo.

    |   - <type_blocking>                                  :Tipo de bloqueo.

    |   - <description_blocking>                           :Descripción de bloqueo.

    |   - <condition>                                      :Condición.

    |   - <days_expiration>                                :Días de expiración.

    | * Autor       : Gianmarcos Perez Rojas.

    | * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

    | * Responsable : Cesar Jimenez.

    | * RDC         : RQ-4657-14   

    |

    | * Revisiones

    | * Fecha            Autor       Motivo del cambio            RDC

    | ----------------------------------------------------------------------------

    | - 17/11/21    Rulman Ferro   Listar orden de compra        RQ 4657-14       

    ************/

	DECLARE

		reg RECORD;

		n_purchase_id       int:=0; 

		n_order_master_id   int:=0;

	BEGIN 

	

	  SELECT b.purchase_id,

	   max(case when  a.estado_request not in (3,5) then coalesce(a.order_id, 0) else 0 end) into n_purchase_id, n_order_master_id

	  FROM     public.purchase b

	  LEFT JOIN "order" a

	  on a.purchase_id = b.purchase_id

	  WHERE b.sucursal = LPAD(vi_sucursal, 6, '0') AND

	        b.caja = LPAD(vi_caja, 6, '0') AND

	        b.purchase_date = to_char(to_date(vi_purchase_date,'dd-mm-yyyy'), 'yyyy-mm-dd') AND

	        b.transaccion = LPAD(vi_transaction, 6, '0')

	  GROUP BY b.purchase_id;

	  

	 

	 IF n_order_master_id = 0 THEN

	  RETURN QUERY  

		 select 

				ARRAY_AGG(a.estado_request) as estado_request, 

				ARRAY_AGG(a.id_qr) as estado, 

				pd.product_id as product_id, 

				MAX(coalesce(pd.quantity_products,0)) as quantity_products, 

				SUM(coalesce(pd.quantity_products_return,0)) as quantity_products_return,

				0 as reason_operation_id,

				'' as reason_operation,

				0 as operation_type_id,

				'' as operation_type, 

				0 as flag_offers,

				0 as flag_returned,

				MAX(case 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60) < current_date then 1  

					 when g.is_transport = 1 then 1

					 else 0

					end) as flag_blocking,

			    MAX(case    

					 when g.is_transport = 1 then 2

					 else 1 

					end) as type_blocking,

				MAX(case 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60) < current_date then 'Pasó la fecha límite de devolución' 

					 when g.is_transport = 1 then 'Producto no transportable' 

					 else '-'

					end) as description_blocking,

				MAX(case 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60)> current_date then /*INICIO CAMBIO RQ 4657-14*/ 'Fec. límite: ' /*FIN CAMBIO RQ 4657-14*/ || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60), 'dd/mm/yyyy') 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60) <= current_date then /*INICIO CAMBIO RQ 4657-14*/'Fec. límite: ' /*FIN CAMBIO RQ 4657-14*/|| to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60), 'dd/mm/yyyy') 

					 else '-'

					end) as sub_title_fecha ,

					(CASE WHEN (g.condition is null) THEN 'A' ELSE g.condition END) as condition,

					coalesce(pd.days_expiration,60) as days_expiration,

					g.mostrar as flag_mostrar

			FROM public.purchase pur 

			inner join public.purchase_detail pd 

			on pd.purchase_id = pur.purchase_id 

			LEFT JOIN "order" a

			on a.purchase_id = pur.purchase_id   

			left join public.classification_products g

			on g.classification_products_id  = pd.classification_products_id 

			  WHERE pur.purchase_id = n_purchase_id 

			GROUP BY pd.product_id , g.condition, pd.days_expiration, g.mostrar  ; 	  

	 ELSE	

	  RETURN QUERY  

			SELECT 

			ARRAY_AGG(a.estado_request) as estado_request, 

			ARRAY_AGG(d.description) as estado, 

			c.product_id as product_id, 

			MAX(coalesce(c.quantity_products,0)) as quantity_products, 

			SUM((case when a.estado_request = 4 then coalesce(c.quantity_products_return_real,0)

				            else 

				 coalesce(c.quantity_products_return,0)

				       end)

			) as quantity_products_return,

			MAX(c.reason_operation_id) as reason_operation_id,

			MAX(f.description) as reason_operation,

			MAX(coalesce(c.operation_type_id,0)) as operation_type_id,

			MAX(e.description) as operation_type, 

			MAX(coalesce(c.flag_offers,0)) as flag_offers,

			MAX(case 

				 when (case when a.estado_request = 4 then c.quantity_products_return_real 

				           else coalesce(c.quantity_products_return,0)

				       end) <> 0 then 1 

				 else 0

				end) as flag_returned,

			MAX(case 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) < current_date then 1  

			     when g.is_transport = 1 then 1

				 else 0 

				end) as flag_blocking,

			MAX(case    

				 when g.is_transport = 1 then 2

				 else 1 

				end) as type_blocking,

			MAX(case 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) < current_date then 'Pasó la fecha límite de devolución'  

				 when g.is_transport = 1 then 'Producto no transportable' 

				 else '-'

				end) as description_blocking,

			MAX(case 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) > current_date then /*INICIO CAMBIO RQ 4657-14*/'Fec. límite: '/*FIN CAMBIO RQ 4657-14*/ || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60), 'dd/mm/yyyy') 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) <= current_date then /*INICIO CAMBIO RQ 4657-14*/'Fec. límite: ' /*FIN CAMBIO RQ 4657-14*/ || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60), 'dd/mm/yyyy') 

				 else '-'

				end) as sub_title_fecha,

				(CASE WHEN (g.condition is null) THEN 'A' ELSE g.condition END) as condition,

		   coalesce(c1.days_expiration ,60) as days_expiration,

		   g.mostrar as flag_mostrar

		FROM public.purchase pur 

		INNER JOIN "order" a

		on a.purchase_id = pur.purchase_id  

		INNER JOIN order_detail c

		ON c.order_id = a.order_id

		INNER JOIN purchase_detail c1

		ON c1.product_id = c.product_id

		   and c1.purchase_id = pur.purchase_id 

		INNER JOIN state_movements d

		ON d.state_movements_id = a.estado_request

		INNER JOIN operation_type e

		ON e.operation_type_id = c.operation_type_id

		INNER JOIN reason_operation f

		ON f.reason_operation_id = c.reason_operation_id

	    left join public.classification_products g

		on g.classification_products_id  = c1.classification_products_id 

		  WHERE pur.purchase_id = n_purchase_id  and a.estado_request in (2,4)

		GROUP BY c.product_id , g.condition, c1.days_expiration, g.mostrar ;

	 END IF;

					 

	END

$$;


