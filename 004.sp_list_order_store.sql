create or replace function sp_list_order_store(vi_sucursal character varying, vi_caja character varying, vi_purchase_date character varying, vi_transaction character varying)
    returns table(estado_request integer[], estado character varying[], product_id character varying, quantity_products integer, quantity_products_return bigint, reason_operation_id integer, reason_operation text, operation_type_id integer, operation_type text, flag_offers integer, flag_returned integer, flag_blocking integer, type_blocking integer, description_blocking text, sub_title_fecha text, condition character varying, days_expiration integer, flag_mostrar integer)
    language plpgsql
as
$$
    /*************

    | * descripcion : function public.sp_list_order_store

    | * proposito   : función para listar las ordenes de tiendas fisicas.

    | * input parameters:

    |   - <vi_sucursal>                           		:sucursal.

    |   - <vi_caja>                           			:caja.

    |   - <vi_purchase_date>                           	:fecha de compra.

    |   - <vi_transaction>                           	:transaccion.

    | * output parameters:

    |   - <estado_request>                                 :estado de solicitud.

    |   - <estado>                                         :estado.

    |   - <product_id>                                     :id del producto.

    |   - <quantity_products>                              :cantidad de productos.

    |   - <quantity_products_return>                       :cantidad de productos devueltos.

    |   - <reason_operation_id>                            :sucursal.

    |   - <reason_operation>                               :monto.

    |   - <operation_type_id>                              :monto afecto.

    |   - <operation_type>                                 :tipo de operación.

    |   - <flag_offers>                                    :bandera de oferta.

    |   - <flag_returned>                                  :bandera de retorno.

    |   - <flag_blocking>                                  :bandera de bloqueo.

    |   - <type_blocking>                                  :tipo de bloqueo.

    |   - <description_blocking>                           :descripción de bloqueo.

    |   - <condition>                                      :condición.

    |   - <days_expiration>                                :días de expiración.

    | * autor       : gianmarcos perez rojas.

    | * proyecto    : rq 4657 - soluciones customer focus: auto-atención / trazabilidad.

    | * responsable : cesar jimenez.

    | * rdc         : rq-4657-14   

    |

    | * revisiones

    | * fecha            autor       motivo del cambio            rdc

    | ----------------------------------------------------------------------------

    | - 17/11/21    rulman ferro   listar orden de compra        rq 4657-14       

    ************/

	declare

		reg record;

		n_purchase_id       int:=0; 

		n_order_master_id   int:=0;

	begin 

	

	  select b.purchase_id,

	   max(case when  a.estado_request not in (3,5) then coalesce(a.order_id, 0) else 0 end) into n_purchase_id, n_order_master_id

	  from     public.purchase b

	  left join "order" a

	  on a.purchase_id = b.purchase_id

	  where b.sucursal = lpad(vi_sucursal, 6, '0') and

	        b.caja = lpad(vi_caja, 6, '0') and

	        b.purchase_date = to_char(to_date(vi_purchase_date,'dd-mm-yyyy'), 'yyyy-mm-dd') and

	        b.transaccion = lpad(vi_transaction, 6, '0')

	  group by b.purchase_id;

	  

	 

	 if n_order_master_id = 0 then

	  return query  

		 select 

				array_agg(a.estado_request) as estado_request, 

				array_agg(a.id_qr) as estado, 

				pd.product_id as product_id, 

				max(coalesce(pd.quantity_products,0)) as quantity_products, 

				sum(coalesce(pd.quantity_products_return,0)) as quantity_products_return,

				0 as reason_operation_id,

				'' as reason_operation,

				0 as operation_type_id,

				'' as operation_type, 

				0 as flag_offers,

				0 as flag_returned,

				max(case 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60) < current_date then 1  

					 when g.is_transport = 1 then 1

					 else 0

					end) as flag_blocking,

			    max(case    

					 when g.is_transport = 1 then 2

					 else 1 

					end) as type_blocking,

				max(case 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60) < current_date then 'pasó la fecha límite de devolución' 

					 when g.is_transport = 1 then 'producto no transportable' 

					 else '-'

					end) as description_blocking,

				max(case 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60)> current_date then /*inicio cambio rq 4657-14*/ 'fec. límite: ' /*fin cambio rq 4657-14*/ || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60), 'dd/mm/yyyy') 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60) <= current_date then /*inicio cambio rq 4657-14*/'fec. límite: ' /*fin cambio rq 4657-14*/|| to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60), 'dd/mm/yyyy') 

					 else '-'

					end) as sub_title_fecha ,

					(case when (g.condition is null) then 'a' else g.condition end) as condition,

					coalesce(pd.days_expiration,60) as days_expiration,

					g.mostrar as flag_mostrar

			from public.purchase pur 

			inner join public.purchase_detail pd 

			on pd.purchase_id = pur.purchase_id 

			left join "order" a

			on a.purchase_id = pur.purchase_id   

			left join public.classification_products g

			on g.classification_products_id  = pd.classification_products_id 

			  where pur.purchase_id = n_purchase_id 

			group by pd.product_id , g.condition, pd.days_expiration, g.mostrar  ; 	  

	 else	

	  return query  

			select 

			array_agg(a.estado_request) as estado_request, 

			array_agg(d.description) as estado, 

			c.product_id as product_id, 

			max(coalesce(c.quantity_products,0)) as quantity_products, 

			sum((case when a.estado_request = 4 then coalesce(c.quantity_products_return_real,0)

				            else 

				 coalesce(c.quantity_products_return,0)

				       end)

			) as quantity_products_return,

			max(c.reason_operation_id) as reason_operation_id,

			max(f.description) as reason_operation,

			max(coalesce(c.operation_type_id,0)) as operation_type_id,

			max(e.description) as operation_type, 

			max(coalesce(c.flag_offers,0)) as flag_offers,

			max(case 

				 when (case when a.estado_request = 4 then c.quantity_products_return_real 

				           else coalesce(c.quantity_products_return,0)

				       end) <> 0 then 1 

				 else 0

				end) as flag_returned,

			max(case 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) < current_date then 1  

			     when g.is_transport = 1 then 1

				 else 0 

				end) as flag_blocking,

			max(case    

				 when g.is_transport = 1 then 2

				 else 1 

				end) as type_blocking,

			max(case 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) < current_date then 'pasó la fecha límite de devolución'  

				 when g.is_transport = 1 then 'producto no transportable' 

				 else '-'

				end) as description_blocking,

			max(case 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) > current_date then /*inicio cambio rq 4657-14*/'fec. límite: '/*fin cambio rq 4657-14*/ || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60), 'dd/mm/yyyy') 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) <= current_date then /*inicio cambio rq 4657-14*/'fec. límite: ' /*fin cambio rq 4657-14*/ || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60), 'dd/mm/yyyy') 

				 else '-'

				end) as sub_title_fecha,

				(case when (g.condition is null) then 'a' else g.condition end) as condition,

		   coalesce(c1.days_expiration ,60) as days_expiration,

		   g.mostrar as flag_mostrar

		from public.purchase pur 

		inner join "order" a

		on a.purchase_id = pur.purchase_id  

		inner join order_detail c

		on c.order_id = a.order_id

		inner join purchase_detail c1

		on c1.product_id = c.product_id

		   and c1.purchase_id = pur.purchase_id 

		inner join state_movements d

		on d.state_movements_id = a.estado_request

		inner join operation_type e

		on e.operation_type_id = c.operation_type_id

		inner join reason_operation f

		on f.reason_operation_id = c.reason_operation_id

	    left join public.classification_products g

		on g.classification_products_id  = c1.classification_products_id 

		  where pur.purchase_id = n_purchase_id  and a.estado_request in (2,4)

		group by c.product_id , g.condition, c1.days_expiration, g.mostrar ;

	 end if;

					 

	end

$$;


